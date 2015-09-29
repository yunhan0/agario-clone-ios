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
    var scoreLabel : [SKLabelNode] = []
    var width        : CGFloat?
    var height       : CGFloat?
    
    init(hudWidth width: CGFloat, hudHeight height: CGFloat) {
        super.init()
        self.width = width
        self.height = height
        self.zPosition = 0x7fffffff
        setup()
    }
    
    func setLeaderboard(lst : [Dictionary<String, Any>]) {
        for i in scoreLabel {
            i.text = ""
        }
        
        for var i = 0; i < min(lst.count, 3); i++ {
            let s = String(lst[i]["name"]!)
            scoreLabel[i].text = String(i + 1) + " . " + (s.characters.count > 0 ? s : "Annoymous")
        }
    }
    
    func setup() {
        // Top Left  : Show Score
        currentScore = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        currentScore.fontColor = UIColor.grayColor()
        currentScore.text = "Score : 0"
        currentScore.fontSize = 12
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
        let topPlayer = SKLabelNode(fontNamed:"AmericanTypewriter-Bold" )
        let sndPlayer = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        let thirdPlayer = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scoreLabel.append(topPlayer)
        scoreLabel.append(sndPlayer)
        scoreLabel.append(thirdPlayer)

        leaderboardLabel.fontColor = UIColor.whiteColor()
        topPlayer.fontColor = UIColor.whiteColor()
        sndPlayer.fontColor = UIColor.whiteColor()
        thirdPlayer.fontColor = UIColor.whiteColor()
        
        leaderboardLabel.text = "Leaderboard"

        let scalingFactor = min(leaderboardWidth / (leaderboardLabel.frame.width * 1.8), leaderboardHeight / (leaderboardLabel.frame.height * 1.8))
        leaderboardLabel.fontSize *= scalingFactor
        topPlayer.fontSize *= scalingFactor
        sndPlayer.fontSize *= scalingFactor
        thirdPlayer.fontSize *= scalingFactor
        
        let midLeaderboard_x = leaderboard.frame.width/2
        let leaderboardLabel_y = leaderboard.frame.height - leaderboardLabel.frame.height * 1.8
        let leaderboardLabelHeight = leaderboardLabel.frame.height
        leaderboardLabel.position = CGPoint(x: midLeaderboard_x,y: leaderboardLabel_y)
        topPlayer.position = CGPoint(x: midLeaderboard_x, y: leaderboardLabel_y - leaderboardLabelHeight * 1.8)
        sndPlayer.position = CGPoint(x: midLeaderboard_x, y: topPlayer.position.y - leaderboardLabelHeight * 1.8)
        thirdPlayer.position = CGPoint(x: midLeaderboard_x, y: sndPlayer.position.y - leaderboardLabelHeight * 1.8)
        
        leaderboard.addChild(leaderboardLabel)
        leaderboard.addChild(topPlayer)
        leaderboard.addChild(sndPlayer)
        leaderboard.addChild(thirdPlayer)
        
        // Bottom Right : Show split button
        let splitBtnWidth = self.width! / 8
        splitBtn = SKSpriteNode(imageNamed: "split-button")
        splitBtn.anchorPoint = CGPoint(x: 0,y: 0)
        splitBtn.size = CGSize(width: splitBtnWidth, height: splitBtnWidth)
        splitBtn.anchorPoint = CGPoint(x: 0, y: 0)
        let splitBtn_x = self.width! - splitBtnWidth - 20
        splitBtn.position = CGPointMake(splitBtn_x, 20)
        
        // Add the elements
        self.addChild(currentScore)
        self.addChild(leaderboard)
        self.addChild(splitBtn)
    }
    
    func moveSplitButtonToLeft() {
        splitBtn.position.x = 20
    }
    
    func moveSplitButtonToRight() {
        splitBtn.position.x = self.width! - self.width! / 8 - 20
    }
    
    func setScore(s : CGFloat) {
        currentScore.text = "Score " + String(s)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}