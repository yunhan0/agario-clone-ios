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
    
    func createBarrier(barrierRadius radius: CGFloat) {
        var barrier = Barrier(barrierRadius: radius)
        var pos_x = CGFloat(arc4random_uniform(3800)) - 1900
        var pos_y = CGFloat(arc4random_uniform(3800)) - 1900
        barrier.position = CGPoint(x: pos_x, y: pos_y)
        scene.addChild(barrier)
    }
    
    func splitBall() {
        for ball in allBalls {
            if (ball.radius >= 25) {
                ball.radius /= 2
                // Remove the prefix of ball.name
                var newBallName = (ball.name! as NSString).substringFromIndex(5)
                // Destroy original balls
                ball.removeFromParent()
                allBalls.removeAtIndex(find(allBalls, ball)!)
                // Create two new balls
                createBall(ballName: newBallName, ballColor: SKColor.redColor(), ballRadius: ball.radius)
                createBall(ballName: newBallName, ballColor: SKColor.redColor(), ballRadius: ball.radius)
            }
        }
    }
    
    func eatFood(nodeA fstNode: Food!, nodeB sndNode: Ball!) {
        // Destroy the food been eaten
        fstNode.removeFromParent()
        allFoods.removeAtIndex(find(allFoods, fstNode)!)
        sndNode.radius += 1
        sndNode.physicsBody?.mass += 1
        sndNode.physicsBody?.friction += 1
        sndNode.drawBall(sndNode.radius)
    }
    
}
