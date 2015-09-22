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
    
    var currentPlayer: Player!
    // Including online player and AI
    var players : [Player] = []
    
    var gameStarted = false
    var playerName = ""
    var splitButton : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        world = self.childNodeWithName("world")!
        foodLayer = world.childNodeWithName("foodLayer")
        barrierLayer = world.childNodeWithName("barrierLayer")
        /* Setup your scene here */
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
        setupHud()
        physicsWorld.contactDelegate = self
        
        // Let barrier spin
        let spin = SKAction.rotateByAngle(CGFloat(M_PI*2), duration: 5)
        let spinForever = SKAction.repeatActionForever(spin)
        for barrier in barrierLayer.children {
            barrier.runAction(spinForever)
        }
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
        
        currentPlayer.refreshState()
        
        for p in players {
            p.refreshState()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!gameStarted || touches.count <= 0) {
            return
        }
        let touch = touches.first! as UITouch
        currentPlayer.move(touch.locationInNode(world))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first! as UITouch
        currentPlayer.move(touch.locationInNode(world))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first! as UITouch
        currentPlayer.floating()

        
        // Capture the touch button event
        let location = touch.locationInNode(self)
        if splitButton.containsPoint(location) {
            currentPlayer.split()
        }
    }
    
    // setup hud
    func setupHud() {
        splitButton = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: 50, height: 50))
        splitButton.position = CGPointMake(self.frame.size.width/1.1, self.frame.size.height/1.2)
        let splitLabel = SKLabelNode(fontNamed: "Courier")
        splitLabel.text = "S"
        splitButton.addChild(splitLabel)
        addChild(splitButton)
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
                        nodeA.split()
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