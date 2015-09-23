//
//  Hud.swift
//  agario
//
//  Created by Yunhan Li on 9/16/15.
//
//

import SpriteKit

class Hud: SKNode {
    var currentScore : SKLabelNode!
    var splitBtn     : SKSpriteNode!
    var leaderboard  : SKSpriteNode!
    var topPlayer    : SKLabelNode!
    var sndPlayer    : SKLabelNode!
    var thirdPlayer  : SKLabelNode!
    var width        : CGFloat?
    var height       : CGFloat?
    
    init(hudWidth width: CGFloat, hudHeight height: CGFloat) {
        super.init()
        self.width = width
        self.height = height
        setup()
    }
    
    func setup() {
//        let rectWidth = self.width! / 5
//        let rectHeight = self.height! / 3
        
        // Top Left  : Show Score
        currentScore = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        currentScore.fontColor = UIColor.grayColor()
        currentScore.text = "Score : 0"
        currentScore.fontSize = 20
        let currentScore_x = currentScore.frame.width
        let currentScore_y = self.height! - currentScore.frame.height
        currentScore.position = CGPointMake(currentScore_x, currentScore_y)
        
        // Top Right : Show Leaderboard
        let leaderboardWidth = self.width! / 5
        let leaderboardHeight = self.height! / 4
        leaderboard = SKSpriteNode()
        leaderboard.size = CGSize(width: leaderboardWidth, height: leaderboardHeight)
        leaderboard.color = UIColor.grayColor().colorWithAlphaComponent(0.3)
        leaderboard.anchorPoint = CGPoint(x: 0,y: 0)
        let leaderboard_x = self.width! - leaderboardWidth
        let leaderboard_y = self.height! - leaderboardHeight
        leaderboard.position = CGPointMake(leaderboard_x,  leaderboard_y)
        
        let leaderboardLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        topPlayer = SKLabelNode(fontNamed:"AmericanTypewriter-Bold" )
        sndPlayer = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        thirdPlayer = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")

        leaderboardLabel.fontColor = UIColor.whiteColor()
        topPlayer.fontColor = UIColor.whiteColor()
        sndPlayer.fontColor = UIColor.whiteColor()
        thirdPlayer.fontColor = UIColor.whiteColor()
        
        leaderboardLabel.fontSize = 20
        topPlayer.fontSize = 18
        sndPlayer.fontSize = 18
        thirdPlayer.fontSize = 18
        
        leaderboardLabel.text = "Leaderboard"
        topPlayer.text = "Leaderboard"
        sndPlayer.text = "Leaderboard"
        thirdPlayer.text = "Leaderboard"
        let midLeaderboard_x = leaderboard.frame.width/2
        let leaderboardLabel_y = leaderboard.frame.height - leaderboardLabel.frame.height * 2
        let leaderboardLabelHeight = leaderboardLabel.frame.height
        leaderboardLabel.position = CGPoint(x: midLeaderboard_x,y: leaderboardLabel_y)
        topPlayer.position = CGPoint(x: midLeaderboard_x, y: leaderboardLabel_y - leaderboardLabelHeight - 10)
        sndPlayer.position = CGPoint(x: midLeaderboard_x, y: topPlayer.position.y - leaderboardLabelHeight - 10)
        thirdPlayer.position = CGPoint(x: midLeaderboard_x, y: sndPlayer.position.y - leaderboardLabelHeight - 10)
        
        leaderboard.addChild(leaderboardLabel)
        leaderboard.addChild(topPlayer)
        leaderboard.addChild(sndPlayer)
        leaderboard.addChild(thirdPlayer)
        
        // Bottom Right : Show split button
        let splitBtnWidth = self.width! / 10
        splitBtn = SKSpriteNode(imageNamed: "split-button")
        splitBtn.anchorPoint = CGPoint(x: 0,y: 0)
        splitBtn.size = CGSize(width: splitBtnWidth, height: splitBtnWidth)
        splitBtn.anchorPoint = CGPoint(x: 0, y: 0)
        let splitBtn_x = self.width! - splitBtnWidth
        splitBtn.position = CGPointMake(splitBtn_x, 0)
        
        // Add the elements
        self.addChild(currentScore)
        self.addChild(leaderboard)
        self.addChild(splitBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
