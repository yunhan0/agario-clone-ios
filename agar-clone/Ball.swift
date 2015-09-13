//
//  Ball.swift
//  agar-clone
//
//  Created by Ming on 9/13/15.
//
//

import SpriteKit

class Ball : SKShapeNode {
    
    var mass = 1
    var moveRequested = false
    var targetLocation = CGPoint(x: 0, y: 0)
    
    init(ballName name : String, ballColor color : SKColor, ballRadius radius : CGFloat) {
        super.init()

        let diameter = radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPointZero, size: CGSize(width: diameter, height: diameter)), nil)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //self.physicsBody?.velocity = CGVector(dx: 100.0, dy: 0.0)
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.applyForce(CGVector(dx: -10, dy: 0))
        
        self.fillColor = color
    }
    
    func moveTowardTarget(targetLocation loc:CGPoint) {
        let v = CGVector(dx: loc.x - self.position.x, dy: loc.y - self.position.y)
        self.physicsBody?.applyForce(v)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}