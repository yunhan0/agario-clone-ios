//
//  Hud.swift
//  agario
//
//  Created by Yunhan Li on 9/16/15.
//
//

import SpriteKit

class Hud: SKScene {
    var hudLayer : SKNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
