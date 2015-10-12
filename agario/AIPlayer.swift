//
//  AIPlayer.swift
//  agario
//
//  Created by Ming on 10/12/15.
//
//

import SpriteKit

class AIPlayer : Player {
    
    var confidenceLevel = 0
    
    override init(playerName name : String, parentNode parent : SKNode, initPosition p : CGPoint) {
        super.init(playerName: name, parentNode: parent, initPosition: p)
        self.children.first!.position = randomPosition()
        self.move(randomPosition())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func randomMove() {
        confidenceLevel = 0
        if let b = self.children.first as! Ball? {
            if b.physicsBody?.velocity == CGVector(dx: 0, dy: 0) {
                //print("a")
                self.move(randomPosition())
            } else if b.position.x + b.radius > 1950 || b.position.x - b.radius < -1950 {
                //print("here", b.position.x, b.radius)
                self.move(randomPosition())
            } else if b.position.y + b.radius > 1950 || b.position.y - b.radius < -1950 {
                //print("there")
                self.move(randomPosition())
            } else {
                // Keep moving
                let scene : GameScene = self.scene as! GameScene
                for food in scene.foodLayer.children as! [Food] {
                    if distance(food.position, p2: self.centerPosition()) < b.radius * 5 {
                        self.move(food.position)
                        return
                    }
                }
            }
        }
    }
    
    func moveAway(player : Player) {
        let p = self.centerPosition()
        let b = player.children.first! as! Ball
        
        let v : CGVector = self.centerPosition() - (player.centerPosition() + (b.physicsBody?.velocity)! * 0.4)
        self.move(CGPoint(x: p.x + v.dx, y: p.y + v.dy))
    }
    
    func chase(player : Player) {
        let p = self.centerPosition()
        let v : CGVector = player.centerPosition() - self.centerPosition()
        self.move(CGPoint(x: p.x + v.dx, y: p.y + v.dy))
    }
    
    override func refreshState() {
        
        if self.children.count == 0 {
            return
        }
        
        let scene : GameScene = self.scene as! GameScene
        
        var targetPlayer : Player? = nil
        var dist : CGFloat = 100000
        
        for player in scene.playerLayer.children as! [Player] {
            if player.name == self.name {
                continue
            }
            let tmpd = distance(player.centerPosition(), p2: self.centerPosition())
            if tmpd < dist {
                dist = tmpd
                targetPlayer = player
            }
        }
        
        let b = self.children.first! as! Ball
        
        if targetPlayer == nil {
            randomMove()
        } else if self.children.count > 1 {
            if b.mass < targetPlayer!.totalMass() * 0.9 {
                self.moveAway(targetPlayer!)
            } else {
                self.randomMove()
            }
        } else if dist > 10 * b.radius {
            self.randomMove()
        } else if self.totalMass() > targetPlayer!.totalMass() * 2.25 {
            self.chase(targetPlayer!)
            confidenceLevel += 1
            if dist < b.radius * 3 && confidenceLevel > 100 {
                // EAT THE BASTARD!
                self.split()
            }
        } else if self.totalMass() < targetPlayer!.totalMass() / CGFloat(min(targetPlayer!.children.count, 4)) * 0.90 {
            self.moveAway(targetPlayer!)
        } else {
            self.randomMove()
        }
        
        super.refreshState()
    }
}