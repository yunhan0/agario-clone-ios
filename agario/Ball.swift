//
//  Ball.swift
//  agar-clone
//
//  Created by Ming on 9/13/15.
//
//

import SpriteKit

class Ball : SKShapeNode {
    
    var targetDirection = CGVector(dx: 0, dy: 0)
    var moveRequested = false
    var maxVelocity = CGFloat(200.0)
    var force = CGFloat(2000.0)
    var radius = CGFloat(0)
    
    init(ballName name : String, ballColor color : SKColor, ballRadius radius : CGFloat) {
        super.init()
        
        self.radius = radius

        let diameter = radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: diameter, height: diameter)), nil)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.mass = 10
        self.physicsBody?.friction = 10
        
        self.fillColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func regulateSpeed() {
        let v = self.physicsBody?.velocity
        
        if v!.dx * v!.dx + v!.dy * v!.dy > maxVelocity * maxVelocity {
            self.physicsBody?.velocity = v!.normalize() * maxVelocity
        }
    }
    
    func move() {
        let v = self.physicsBody?.velocity
        if targetDirection.dx * targetDirection.dx + targetDirection.dy * targetDirection.dy > radius * radius {
            self.physicsBody?.applyForce(targetDirection.normalize() * force)
        } else {
            self.physicsBody?.velocity = v! * 0.9
        }
    }
    
    func moveTowardTarget(targetLocation loc:CGPoint) {
        targetDirection = loc - self.position
        moveRequested = true
    }
}