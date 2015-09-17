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
    var allBalls : [Ball]!
    var allFoods : [Food]!
    init(sceneNode scene: SKNode) {
        self.scene = scene
        allBalls = []
        allFoods = []
    }
    
    func splitBall() {
        for ball in allBalls {
            if (ball.radius >= 25) {
                ball.radius /= 2
                ball.drawBall(ball.radius)
                ball.physicsBody?.mass /= 2
                ball.physicsBody?.friction /= 2
                // Ugly demo
                createBall(ballName: "Cat", ballColor: SKColor.redColor(), ballRadius: ball.radius)
            }
        }
    }
    
    func createBall(ballName name: String, ballColor color: SKColor, ballRadius radius: CGFloat) {
        var ball = Ball(ballName: name, ballColor: color, ballRadius: radius)
        if !allBalls.isEmpty {
            ball.position = CGPoint(x: allBalls[0].position.x + allBalls[0].radius * 3, y: allBalls[0].position.y + allBalls[0].radius * 3)
        } else {
            ball.position = CGPoint(x: 30, y: 30)
        }
        allBalls.append(ball)
        scene.addChild(ball)
        // Speed
    }
    
    func createFood(foodColor color: SKColor, foodRadius radius: CGFloat) {
        if allFoods.count <= 2000 {
            var food = Food(foodColor: color, foodRadius: radius)
            var pos_x = CGFloat(arc4random_uniform(4000)) - 2000
            var pos_y = CGFloat(arc4random_uniform(4000)) - 2000
            food.position = CGPoint(x: pos_x, y: pos_y)
            allFoods.append(food)
            scene.addChild(food)
        }
    }
}
