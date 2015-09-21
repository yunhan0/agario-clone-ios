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
    var maxVelocity     = CGFloat(200.0)
    var force           = CGFloat(5000.0)
    var radius          = CGFloat(0)
    var color:Int?      = nil
    var mass : CGFloat!
    var labelText : String?
    
    init(ballName name : String, ballColor color : Int, ballMass mass : CGFloat, ballPosition pos : CGPoint) {
        super.init()
        self.name   = "ball"
        self.position = pos
        self.color  = color
        self.setMass(mass)
        
        //Graphic
        self.drawBall()
        // Physics
        self.initPhysicsBody()
        
        // Name label
        self.labelText = name
        if let nm = self.labelText {
            let nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            nameLabel.text = nm
            nameLabel.fontSize = 16
            nameLabel.horizontalAlignmentMode = .Center
            nameLabel.verticalAlignmentMode = .Center
            self.addChild(nameLabel)
        }
    }
    
    convenience init(ballName name : String) {
        self.init(ballName: name, ballColor: randomColor(), ballMass: 10, ballPosition : CGPoint(x: 0, y: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMass(m : CGFloat) {
        self.mass = m
        self.radius = sqrt(m) * 10.0
    }
    
    func drawBall() {
        let diameter = self.radius * 2
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -self.radius, y: -self.radius), size: CGSize(width: diameter, height: diameter)), nil)
        self.fillColor = UIColor(hex: self.color!)
    }
    
    func initPhysicsBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.mass = mass
        self.physicsBody?.friction = 1000
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GlobalConstants.Category.ball
        self.physicsBody?.collisionBitMask = GlobalConstants.Category.wall
        self.physicsBody?.contactTestBitMask = GlobalConstants.Category.barrier | GlobalConstants.Category.ball
        self.zPosition = GlobalConstants.ZPosition.ball
    }
    
    func regulateSpeed() {
        let v = self.physicsBody?.velocity
        
        if v!.dx * v!.dx + v!.dy * v!.dy > maxVelocity * maxVelocity {
            //self.physicsBody?.velocity = v!.normalize() * maxVelocity
            self.physicsBody?.velocity = v! * 0.5
        }
    }
    
    func refresh() {
        if targetDirection.dx * targetDirection.dx + targetDirection.dy * targetDirection.dy > radius * radius {
            self.physicsBody?.applyForce(targetDirection.normalize() * force)
        }
    }
    
    func moveTowardTarget(targetLocation loc:CGPoint) {
        targetDirection = loc - self.position
    }
    
    func split() {
        let ball1 = Ball(ballName: self.name!, ballColor: self.color!,
            ballMass: self.mass / 2, ballPosition: self.position)
        let ball2 = Ball(ballName: self.name!, ballColor: self.color!,
            ballMass: self.mass / 2, ballPosition: self.position)
        let p = self.parent! as SKNode
        self.removeFromParent()
        p.addChild(ball1)
        p.addChild(ball2)
    }
    
    func eatFood(food : Food) {
        // Destroy the food been eaten
        food.removeFromParent()
        self.setMass(self.mass! + 1)
        self.drawBall()
        let oldv = self.physicsBody?.velocity
        self.initPhysicsBody()
        self.physicsBody?.velocity = oldv!
    }
}