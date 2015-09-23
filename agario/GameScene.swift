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
        world = self.childNodeWithName("world")!
        foodLayer = world.childNodeWithName("foodLayer")
        barrierLayer = world.childNodeWithName("barrierLayer")
        /* Setup your scene here */
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
 
        // Setup Hud
        hudLayer = Hud(hudWidth: self.frame.width, hudHeight: self.frame.height)
        self.addChild(hudLayer)
        physicsWorld.contactDelegate = self
    }
    
    func start() {
        // Create Foods
        for _ in 0..<100 {
            self.spawnFood()
        }
        // Create Barriers
        for _ in 0..<15 {
            self.spawnBarrier()
        }
        
        // New Player
        self.currentPlayer = Player(playerName: playerName, parentNode: self.world)
        
        for _ in 0..<8 {
            players += [StupidPlayer(playerName: "Stupid AI", parentNode: self.world)]
        }
        gameStarted = true
    }
    
    func spawnFood() {
        if foodLayer.children.count <= GlobalConstants.FoodLimit {
            foodLayer.addChild(Food(foodColor: randomColor()))
        }
    }
    
    func spawnBarrier() {
        if barrierLayer.children.count <= GlobalConstants.BarrierLimit {
            barrierLayer.addChild(Barrier())
        }
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        world.position = CGPoint(x: -position.x + CGRectGetMidX(frame),
            y: -position.y + CGRectGetMidY(frame))
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
        
        for _ in 0..<3 {
            spawnFood()
        }
        
        spawnBarrier()
        
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
        
//        let scaleFactorBallNumber = 1.0 + log(CGFloat(currentPlayer.children.count)) * 0.15
//        world.xScale = 1 / scaleFactorBallNumber
//        world.yScale = 1 / scaleFactorBallNumber
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!gameStarted || touches.count <= 0) {
            return
        }
        let touch : UITouch = touches.first!
        touchingLocation = touch
        //currentPlayer.move(touch.locationInNode(world))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch : UITouch = touches.first!
        touchingLocation = touch
        //currentPlayer.move(touch.locationInNode(world))
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
                        nodeA.split(4)
                        sndNode.removeFromParent()
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