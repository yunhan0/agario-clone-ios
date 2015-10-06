//
//  Food.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//
import SpriteKit

class Food : SKSpriteNode {
    
    var radius = GlobalConstants.FoodRadius
    
    static var counter : Int = 0
    
    init(foodColor color: Int){
        //super.init()
        super.init(texture: nil, color: UIColor(hex: color), size: CGSize(width: radius * 2, height: radius * 2))
        self.name   = "food-" + NSUUID().UUIDString
        //let diameter = radius * 2
        //self.path = CGPathCreateWithEllipseInRect(CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: diameter, height: diameter)), nil)
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        //self.fillColor = UIColor(hex: color)
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
    
    func toJSON() -> JSON {
        let json : JSON = ["name": self.name!, "color": colorToHex(self.color),
            "x": Double(self.position.x), "y": Double(self.position.y)]
        return json
    }
}