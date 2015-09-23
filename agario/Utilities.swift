//
//  Utilities.swift
//  agario
//
//  Created by Ming on 9/13/15.
//
//

import SpriteKit

extension CGVector {
    func normalize() -> CGVector {
        let d = length()
        
        return CGVector(dx: dx / d, dy: dy / d)
    }
    
    func length() -> CGFloat {
        return hypot(dx, dy)
    }
}

func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGVector {
    return CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
}

func randomColor() -> Int {
    let maxIdx = GlobalConstants.Color.count - 1
    let randi  = Int(arc4random_uniform(UInt32(maxIdx)))
    return GlobalConstants.Color[randi]
}

func randomPosition() -> CGPoint {
    let width = UInt32(GlobalConstants.MapSize.width)
    let height = UInt32(GlobalConstants.MapSize.height)
    let pos_x = CGFloat(arc4random_uniform(width)) - CGFloat(width / 2)
    let pos_y = CGFloat(arc4random_uniform(height)) - CGFloat(height / 2)
    return CGPoint(x: pos_x, y: pos_y)
}

func scheduleRun(target: SKNode, time: NSTimeInterval, block: dispatch_block_t) {
    let waitAction = SKAction.waitForDuration(time)
    let runAction = SKAction.runBlock(block)
    target.runAction(SKAction.sequence([waitAction, runAction]))
}

func scheduleRunRepeat(target: SKNode, time: NSTimeInterval, block: dispatch_block_t) {
    let waitAction = SKAction.waitForDuration(time)
    let runAction = SKAction.runBlock(block)
    target.runAction(SKAction.repeatActionForever(SKAction.sequence([waitAction, runAction])))
}

func distance(p1 : CGPoint, p2 : CGPoint) -> CGFloat {
    let v = p1 - p2 as CGVector
    return v.length()
}

func circleOverlapArea(r1: CGFloat, r2: CGFloat, d: CGFloat) -> CGFloat {
    if d >= r1 + r2 {
        return 0
    }
    if r2 + d <= r1 {
        return circleArea(r2)
    }
    //let t = (d * d - r2 * r2 + r1 * r1) * (d * d - r2 * r2 + r1 * r1)
    //let a = 1.0 / d * sqrt(4 * d * d * r1 * r1 - t)
    let d1 = (d * d - r2 * r2 + r1 * r1) / (2 * d)
    let d2 = (d - d1)
    
    let f = { (rr : CGFloat, dd : CGFloat) -> CGFloat in
        return rr * rr * acos(dd / rr) - dd * sqrt(rr * rr - dd * dd)
    }
    return f(r1, d1) + f(r2, d2)
}

func circleArea(r : CGFloat) -> CGFloat {
    return CGFloat(M_PI) * r * r
}