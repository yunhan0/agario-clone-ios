//
//  GameScene.swift
//  agar-clone
//
//  Created by Ming on 8/24/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var world : SKNode!
    var foodLayer : SKNode!
    var barrierLayer : SKNode!
    var hudLayer : Hud!
    
    var currentPlayer: Player!
    // Including online player and AI
    var players : [Player] = []
    
    var gameStarted = false
    var playerName = ""
    var splitButton : SKSpriteNode!
    var currentMass : SKLabelNode!
    
    var touchingLocation : UITouch? = nil
    
    override func didMoveToView(view: SKView) {
        paused = true
        
        world = self.childNodeWithName("world")!
        foodLayer = world.childNodeWithName("foodLayer")
        barrierLayer = world.childNodeWithName("barrierLayer")
        //self.anchorPoint = CGPointMake(0.5, 0.5)
        /* Setup your scene here */
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
 
        // Setup Hud
        hudLayer = Hud(hudWidth: self.frame.width, hudHeight: self.frame.height)
        self.addChild(hudLayer)
        physicsWorld.contactDelegate = self
        
        scheduleRunRepeat(self, time: Double(GlobalConstants.BarrierRespawnInterval)) { () -> Void in
            if self.barrierLayer.children.count < GlobalConstants.BarrierLimit {
                self.spawnBarrier()
            }
        }
    }
    
    func start() {
        // Create Foods
        self.spawnFood(100)
        // Create Barriers
        self.spawnBarrier(15)
        
        // New Player
        self.currentPlayer = Player(playerName: playerName, parentNode: self.world)
        
        for _ in 0..<8 {
            players += [StupidPlayer(playerName: "Stupid AI", parentNode: self.world)]
        }
        gameStarted = true
        paused = false
    }
    
    func spawnFood(n : Int = 1) {
        for _ in 0..<n {
            foodLayer.addChild(Food(foodColor: randomColor()))
        }
    }
    
    func spawnBarrier(n : Int = 1) {
        for _ in 0..<n {
            barrierLayer.addChild(Barrier())
        }
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        let screenLocation = self.convertPoint(position, fromNode: world)
//        world.position = CGPoint(x: -position.x + CGRectGetMidX(frame),
//            y: -position.y + CGRectGetMidY(frame))
        let screenCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        world.position = world.position - screenLocation + screenCenter
    }
    
    override func didSimulatePhysics() {
        if (!gameStarted) {
            return
        }
        
        world.enumerateChildNodesWithName("//ball", usingBlock: {
            node, stop in
            let ball = node as! Ball
            ball.regulateSpeed()
        })
        
        
        centerWorldOnPosition(currentPlayer.centerPosition())
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (!gameStarted) {
            return
        }
        
        let foodRespawnNumber = min(GlobalConstants.FoodLimit - foodLayer.children.count,
            GlobalConstants.FoodRespawnRate)
        spawnFood(foodRespawnNumber)
        
        if let t = touchingLocation {
            currentPlayer.move(t.locationInNode(world))
        } else {
            currentPlayer.floating()
        }
        
        currentPlayer.refreshState()
        
        for p in players {
            p.refreshState()
        }
        let m = currentPlayer.totalMass()
        hudLayer.currentScore.text = "Score : " + String(m)
        
        let scaleFactorBallNumber = 1.0 + (log(CGFloat(currentPlayer.children.count)) - 1) * 0.2
        let scaleFactorBallMass = 1.0 + (log10(CGFloat(currentPlayer.totalMass())) - 1) * 1.0
        world.setScale(1 / scaleFactorBallNumber / scaleFactorBallMass)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!gameStarted || touches.count <= 0) {
            return
        }
        let touch : UITouch = touches.first!
        touchingLocation = touch
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch : UITouch = touches.first!
        touchingLocation = touch
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        touchingLocation = nil
        
//        for touch in touches {
//            let screenLocation = touch.locationInNode(self)
//            if splitButton.containsPoint(screenLocation) {
//                currentPlayer.split()
//            } else  {
//            }
//        }
    }
}

//Contact Detection
extension GameScene : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        var fstBody : SKPhysicsBody
        var sndBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fstBody = contact.bodyA
            sndBody = contact.bodyB
        } else {
            fstBody = contact.bodyB
            sndBody = contact.bodyA
        }
        
        // Purpose of using "if let" is to test if the object exist
        if let fstNode = fstBody.node {
            if let sndNode = sndBody.node {
                if fstNode.name == "ball" && sndNode.name == "barrier" {
                    let nodeA = fstNode as! Ball
                    let nodeB = sndNode as! Barrier
                    if nodeA.radius >= nodeB.radius {
                        if let p = nodeA.parent {
                            nodeA.split(min(4, 16 - p.children.count + 1))
                            sndNode.removeFromParent()
                        }
                    }
                }
                if fstNode.name == "food" && sndNode.name == "ball" {
                    let ball = sndNode as! Ball
                    //ball.eatFood(fstNode as! Food)
                    ball.beginContact(fstNode as! Food)
                }
                
                if fstNode.name == "ball" && sndNode.name == "ball" {
                    var ball1 = fstNode as! Ball // Big
                    var ball2 = sndNode as! Ball // Small
                    if ball2.mass > ball1.mass {
                        let tmp = ball2
                        ball2 = ball1
                        ball1 = tmp
                    }
                    ball1.beginContact(ball2)
                }
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var fstBody : SKPhysicsBody
        var sndBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fstBody = contact.bodyA
            sndBody = contact.bodyB
        } else {
            fstBody = contact.bodyB
            sndBody = contact.bodyA
        }
        if let fstNode = fstBody.node {
            if let sndNode = sndBody.node {
                if fstNode.name == "food" && sndNode.name == "ball" {
                    let ball = sndNode as! Ball
                    ball.endContact(fstNode as! Food)
                }
                
                if fstNode.name == "ball" && sndNode.name == "ball" {
                    var ball1 = fstNode as! Ball // Big
                    var ball2 = sndNode as! Ball // Small
                    if ball2.mass > ball1.mass {
                        let tmp = ball2
                        ball2 = ball1
                        ball1 = tmp
                    }
                    ball1.endContact(ball2)
                }
            }
        }
    }
}