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
    var ballName : String?
    var readyMerge = false
    var impulsive = true
    var contacted : Set<SKNode> = []
    
    init(ballName name : String?, ballColor color : Int, ballMass mass : CGFloat, ballPosition pos : CGPoint) {
        super.init()
        self.name   = "ball"
        self.position = pos
        self.color  = color
        self.setMass(mass)
        
        //Graphic
        self.drawBall()
        // Physics
        self.initPhysicsBody()
        
        self.zPosition = self.mass
        
        // Name label
        self.ballName = name
        if let nm = self.ballName {
            let nameLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
            nameLabel.text = nm
            nameLabel.fontSize = 16
            nameLabel.horizontalAlignmentMode = .Center
            nameLabel.verticalAlignmentMode = .Center
            self.addChild(nameLabel)
        }
        
        self.resetReadyMerge()
        scheduleRun(self, time: 0.5) { () -> Void in
            self.impulsive = false
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
        self.zPosition = m
        self.force = 5000.0 * self.mass / 10.0
        self.maxVelocity = 200.0 / log10(self.mass)
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
        //self.zPosition = GlobalConstants.ZPosition.ball
    }
    
    func regulateSpeed() {
        if self.impulsive {
            return
        }
        let v = self.physicsBody?.velocity
        
        if v!.dx * v!.dx + v!.dy * v!.dy > maxVelocity * maxVelocity {
            self.physicsBody?.velocity = v!.normalize() * maxVelocity
            //self.physicsBody?.velocity = v! * 0.99
        }
    }
    
    func refresh() {
        if targetDirection.dx * targetDirection.dx + targetDirection.dy * targetDirection.dy > radius * radius {
            self.physicsBody?.applyForce(targetDirection.normalize() * force)
            //self.physicsBody?.velocity = targetDirection.normalize() * maxVelocity
        }
        
        for node in contacted {
            if node.parent == nil || !node.inParentHierarchy(node.parent!) {
                contacted.remove(node)
            }
            if (node.name == "ball") {
                let ball = node as! Ball
                if ball.parent == self.parent { // Sibling
                    if self.readyMerge && ball.readyMerge {
                        self.mergeBall(ball)
                        contacted.remove(node)
                    } else {
                        
                    }
                } else { // Enemy
                    if self.mass - ball.mass > max(ball.mass * 0.05, 10) {
                        let d = distance(self.position, p2: ball.position)
                        let a = circleOverlapArea(self.radius, r2: ball.radius, d: d)
                        if a > 0 && a > circleArea(ball.radius) * 0.75 {
                            self.eatBall(ball)
                            contacted.remove(node)
                        }
                    }
                }
            } else if (node.name == "food") {
                if self.containsPoint(node.position) {
                    self.eatFood(node as! Food)
                    contacted.remove(node)
                }
            }
        }
    }
    
    func moveTowardTarget(targetLocation loc:CGPoint) {
        targetDirection = loc - self.position
    }
    
    func split() {
        let ball1 = Ball(ballName: self.ballName, ballColor: self.color!,
            ballMass: self.mass / 2, ballPosition: self.position)
        let ball2 = Ball(ballName: self.ballName, ballColor: self.color!,
            ballMass: self.mass / 2, ballPosition: self.position)
        if let v = self.physicsBody?.velocity {
            ball2.physicsBody?.velocity = v.normalize() * ball2.maxVelocity * 2
//            let vn = v.normalize()
//            let dx = vn.dx * 2 * ball2.maxVelocity * ball2.mass
//            let dy = vn.dy * 2 * ball2.maxVelocity * ball2.mass
//            ball2.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
            ball1.physicsBody?.velocity = v
        }
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
    
    func resetReadyMerge() {
        self.readyMerge = false
        scheduleRun(self, time: 30) { () -> Void in
            self.readyMerge = true
        }
    }
    
    func mergeBall(ball : Ball) {
        self.eatBall(ball)
        self.resetReadyMerge()
    }
    
    func eatBall(ball : Ball) {
        ball.removeFromParent()
        self.setMass(self.mass! + ball.mass)
        self.drawBall()
        let oldv = self.physicsBody?.velocity
        self.initPhysicsBody()
        self.physicsBody?.velocity = oldv!.normalize() * self.maxVelocity
    }
    
    func beginContact(node : SKNode) {
        contacted.insert(node)
    }
    
    func endContact(node : SKNode) {
        contacted.remove(node)
    }
}