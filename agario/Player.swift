//
//  Player.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//

import SpriteKit

class Player {
    var name: String
    var sceneCallback : SceneCallback!
    
    init(playerName name : String, callback sceneCallback: SceneCallback) {
        self.name = name
        self.sceneCallback = sceneCallback
        sceneCallback.createBall(ballName: name, ballColor: SKColor.redColor(), ballRadius: 25)
    }
    
    
}
