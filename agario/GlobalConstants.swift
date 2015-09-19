//
//  GlobalConstants.swift
//  agario
//
//  Created by Yunhan Li on 9/18/15.
//
//
import SpriteKit
struct GlobalConstants {
    struct Category {
        static let wall      :UInt32 = 0b0001;
        static let food      :UInt32 = 0b0010;
        static let ball      :UInt32 = 0b0011;
        static let barrier   :UInt32 = 0b0100;
    }
    
    struct ZPosition {
        static let food    :CGFloat = 1
        static let ball    :CGFloat = 2
        static let barrier :CGFloat = 3
        static let wall    :CGFloat = 4
    }
}