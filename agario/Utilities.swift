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