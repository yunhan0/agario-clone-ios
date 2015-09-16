//
//  Food.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//
import SpriteKit

class Food : SKShapeNode {
    var radius = CGFloat(0)
    init(foodColor color: SKColor, foodRadius radius: CGFloat){
        super.init()
        
        self.radius = radius        
        let diameter = radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: diameter, height: diameter)), nil)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.fillColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}