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
    var player: Player!
    var sceneCallback : SceneCallback!
    var gameStarted = false
    var playerName = ""
    var splitButton : SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        world = self.childNodeWithName("world")!
        
        /* Setup your scene here */
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
        setupHud()
        physicsWorld.contactDelegate = self
    }
    
    func start() {
        gameStarted = true
        // Scene Callback
        self.sceneCallback = SceneCallback(sceneNode: self.world)
        // Create Foods
        for food in 0..<100 {
            sceneCallback.createFood(foodColor: SKColor.greenColor(), foodRadius: 10)
        }
        // Create Barriers
        for barrier in 0..<15 {
            sceneCallback.createBarrier(barrierRadius: 70)
        }
        
        // New Player
        self.player = Player(playerName: playerName, callback: sceneCallback)
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        world.position = CGPoint(x: -position.x + CGRectGetMidX(frame),
            y: -position.y + CGRectGetMidY(frame))
    }
    
    override func didEvaluateActions() {
        if (!gameStarted) {
            return
        }
        
        for ball in sceneCallback.allBalls {
            ball.regulateSpeed()
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (!gameStarted) {
            return
        }
        
        for ball in sceneCallback.allBalls {
            ball.move()
            centerWorldOnPosition(ball.position)
        }
        
        for food in 0..<3 {
            sceneCallback.createFood(foodColor: SKColor.greenColor(), foodRadius: 10)
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!gameStarted || touches.count <= 0) {
            return
        }
        let touch = touches.first as! UITouch

        for ball in sceneCallback.allBalls {
            ball.moveTowardTarget(targetLocation: touch.locationInNode(world))
        }
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first as! UITouch
        
        for ball in sceneCallback.allBalls {
            ball.moveTowardTarget(targetLocation: touch.locationInNode(world))
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first as! UITouch
        for ball in sceneCallback.allBalls {
            ball.targetDirection = CGVector(dx: 0, dy: 0)
        }
        
        // Capture the touch button event
        let location = touch.locationInNode(self)
        if splitButton.containsPoint(location) {
            sceneCallback.splitBall()
        }

    }
    
    // setup hud
    func setupHud() {
//        let rankLabel = SKLabelNode(fontNamed: "Courier")
//        rankLabel.name = "rankHud"
//        rankLabel.fontColor = SKColor.greenColor()
//        rankLabel.text = "Learderboard"
//        rankLabel.position = CGPointMake(self.frame.size.width/1.2, self.frame.size.height/1.2)
//        addChild(rankLabel)
        
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
                if fstNode.name!.hasPrefix("ball_") && sndNode.name == "barrier" {
                    let nodeA = fstNode as! Ball
                    let nodeB = sndNode as! Barrier
                    if nodeA.radius >= nodeB.radius {
                        sceneCallback.splitBall()
                    }
                }
                if fstNode.name == "food" && sndNode.name!.hasPrefix("ball_") {
                    sceneCallback.eatFood(nodeA: fstNode as! Food, nodeB: sndNode as! Ball)
                }
                
                if fstNode.name!.hasPrefix("ball_") && sndNode.name!.hasPrefix("ball_") {
                    // Not implemented yet
                }
            }
        }
    }
}