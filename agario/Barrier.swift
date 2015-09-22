//
//  Barrier.swift
//  agario
//
//  Created by Yunhan Li on 9/18/15.
//
//

import SpriteKit

class Barrier : SKSpriteNode {
    var radius = GlobalConstants.BarrierRadius
    
    init() {
        super.init(texture: SKTexture(imageNamed: "barrier"),
            color: SKColor.whiteColor(),
            size: CGSize(width: 2 * radius, height: 2 * radius))
        self.name   = "barrier"
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = GlobalConstants.Category.barrier
        self.physicsBody?.collisionBitMask = GlobalConstants.Category.wall | GlobalConstants.Category.barrier
        self.physicsBody?.contactTestBitMask = GlobalConstants.Category.ball | GlobalConstants.Category.food
        self.zPosition = GlobalConstants.ZPosition.barrier
        
        self.position = randomPosition()
        
        // Let barrier spin
        let spin = SKAction.rotateByAngle(CGFloat(M_PI*2), duration: 10)
        self.runAction(SKAction.repeatActionForever(spin))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}