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
    var defaultBall : Ball!
    var otherBalls : [Ball]!
    var gameStarted = false
    
    let rankHudName = "randHud"
    
    override func didMoveToView(view: SKView) {
        
        world = self.childNodeWithName("world")!
        
        /* Setup your scene here */
        
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
        setupHud()
    }
    
    func start() {
        gameStarted = true
        
        self.defaultBall = Ball(ballName: "hello", ballColor: SKColor.redColor(), ballRadius: 20)
        self.defaultBall.position = CGPoint(x: 0, y: 0)
        world.addChild(self.defaultBall)
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        world.position = CGPoint(x: -position.x + CGRectGetMidX(frame),
            y: -position.y + CGRectGetMidY(frame))
    }
    
    override func didEvaluateActions() {
        if (!gameStarted) {
            return
        }
        
        defaultBall.regulateSpeed()
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (!gameStarted) {
            return
        }
        
        defaultBall.move()

        centerWorldOnPosition(defaultBall.position)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!gameStarted || touches.count <= 0) {
            return
        }
        let touch = touches.first as! UITouch
        defaultBall.moveTowardTarget(targetLocation: touch.locationInNode(world))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first as! UITouch
        defaultBall.moveTowardTarget(targetLocation: touch.locationInNode(world))
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !gameStarted || touches.count <= 0 {
            return
        }
        
        let touch = touches.first as! UITouch
        defaultBall.targetDirection = CGVector(dx: 0, dy: 0)
    }
    
    // setup hud
    func setupHud() {
        let rankLabel = SKLabelNode(fontNamed: "Courier")
        rankLabel.name = rankHudName
        rankLabel.fontColor = SKColor.greenColor()
        rankLabel.text = "Learderboard"
        rankLabel.position = CGPointMake(self.frame.size.width/1.2, self.frame.size.height/1.2)
        addChild(rankLabel)
    }
}
