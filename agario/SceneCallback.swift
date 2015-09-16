//
//  sceneCallback.swift
//  agario
//
//  Created by Yunhan Li on 9/15/15.
//
//

import SpriteKit

class SceneCallback {
    let scene : SKNode
    
    init(sceneNode scene: SKNode) {
        self.scene = scene
    }
    
    func split(ball : Ball) {
        ball.radius /= 2
        ball.physicsBody?.mass /= 2
    }
    
    func createBall(ballName name: String, ballColor color: SKColor, ballRadius radius: CGFloat) {
        var ball = Ball(ballName: name, ballColor: color, ballRadius: radius)
        ball.position = CGPoint(x: 30, y: 30)
        scene.addChild(ball)
        // Speed
    }
    
    func createFood(foodColor color: SKColor, foodRadius radius: CGFloat) {
        var food = Food(foodColor: color, foodRadius: radius)
        food.position = CGPoint(x:0, y:0)
        scene.addChild(food)
    }

}
