//
//  Food.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//
import SpriteKit

class Food : SKShapeNode {
    
    var radius = GlobalConstants.FoodRadius
    
    init(foodColor color: Int){
        super.init()
        self.name   = "food"
        let diameter = radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: diameter, height: diameter)), nil)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.fillColor = UIColor(hex: color)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = GlobalConstants.Category.food
        self.physicsBody?.collisionBitMask = GlobalConstants.Category.wall
        self.physicsBody?.contactTestBitMask = GlobalConstants.Category.ball | GlobalConstants.Category.barrier
        self.zPosition = GlobalConstants.ZPosition.food
        
        self.position = randomPosition()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}