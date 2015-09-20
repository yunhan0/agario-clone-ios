//
//  Barrier.swift
//  agario
//
//  Created by Yunhan Li on 9/18/15.
//
//

import SpriteKit

class Barrier : SKShapeNode {
    var radius = CGFloat(0)
    
    init(barrierRadius radius: CGFloat) {
        super.init()
        self.name   = "barrier"
        self.radius = radius
        let diameter = radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: diameter, height: diameter)), nil)
        self.fillColor = SKColor.whiteColor()
        self.fillTexture = SKTexture(imageNamed:"barrier")
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = GlobalConstants.Category.barrier
        self.physicsBody?.collisionBitMask = GlobalConstants.Category.wall | GlobalConstants.Category.barrier
        self.physicsBody?.contactTestBitMask = GlobalConstants.Category.ball | GlobalConstants.Category.food
        self.zPosition = GlobalConstants.ZPosition.barrier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}