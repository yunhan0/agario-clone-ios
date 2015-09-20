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
        var d = length()
        
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
    var randi  = Int(arc4random_uniform(UInt32(maxIdx)))
    return GlobalConstants.Color[randi]
}