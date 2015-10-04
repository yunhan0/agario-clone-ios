//
//  Player.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//

import SpriteKit

class Player : SKNode {
    
    var displayName : String = ""
    
    init(playerName name : String, parentNode parent : SKNode) {
        super.init()
        self.position = CGPoint(x: 0, y: 0)
        
        self.displayName = name
        self.name = "player-"
        
        let ball = Ball(ballName: self.displayName)
        self.addChild(ball)
        
        //self.zPosition = GlobalConstants.ZPosition.ball
        
        parent.addChild(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func centerPosition() -> CGPoint {
        //let count = CGFloat(self.children.count)
        var x = CGFloat(0)
        var y = CGFloat(0)
        let m = self.totalMass()
        for ball in self.children as! [Ball] {
            x += ball.position.x * ball.mass / m
            y += ball.position.y * ball.mass / m
        }
        return CGPoint(x: x, y: y)
    }
    
    func totalMass() -> CGFloat {
        var ret : CGFloat = 0
        for ball in self.children as! [Ball] {
            ret += ball.mass
        }
        return ret
    }
    
    func move(pos : CGPoint) {
        for ball in self.children as! [Ball] {
            ball.moveTowardTarget(targetLocation: pos)
        }
    }
    
    func floating() {
        for ball in self.children as! [Ball] {
            ball.targetDirection = CGVector(dx:0, dy: 0)
        }
    }
    
    // Potentially used for AI and online player
    func refreshState() {
        for ball in self.children as! [Ball] {
            ball.refresh()
        }
    }
    
    func checkDeath() {
        if self.children.count == 0 {
            self.removeFromParent()
        }
    }
    
    func isDead() -> Bool {
        return self.children.count == 0
    }
    
    func split() {
        for ball in self.children as! [Ball] {
            if self.children.count < 15 && ball.mass >= 25 {
                ball.split()
            }
        }
    }
}
