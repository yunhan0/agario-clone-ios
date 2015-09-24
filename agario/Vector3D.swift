//
//  Vector3D.swift
//  agario
//
//  Created by Yunhan Li on 9/24/15.
//
//

import SpriteKit

struct Vector3D {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    
    init(x: CGFloat, y: CGFloat, z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x: Double, y: Double, z: Double) {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        self.z = CGFloat(z)
    }
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y + z*z)
    }
}

//func *(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
//    return Vector3D(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
//}

func dot(lhs : Vector3D, rhs : Vector3D) -> CGFloat {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}

func /(lhs: Vector3D, rhs: CGFloat) -> Vector3D {
    return Vector3D(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

func *(lhs: Vector3D, rhs: CGFloat) -> Vector3D {
    return Vector3D(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

func -(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

func +(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}



