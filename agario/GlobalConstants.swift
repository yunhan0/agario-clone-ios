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
    
    static let Color = [
        0xF44336, // Red
        0xE91E63, // Pink
        0x9C27B0, // Purple
        0x3F51B5, // DarkBlue
        0x03A9F4, // LightBlue
        0xFFEB3B, // Yellow
        0xFF9800, // Orange
        0x4CAF50, // DarkGreen
        0x8bc34a, // Lime
        0x212121, // DarkGray
    ]
}