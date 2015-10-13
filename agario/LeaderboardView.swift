//
//  Leaderboard.swift
//  agario
//
//  Created by Yunhan Li on 10/13/15.
//
//

import UIKit

class LeaderboardView: UIView {
    var exitBtn   = UIButton()
    var lbContent : [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setLeaderboardContent(l : [Dictionary<String, Any>]) {
        for i in lbContent {
            i.text = ""
        }
        
        for var i = 0; i < min(l.count, 5); i++ {
            let name = String(l[i]["name"]!)
            let score = String(l[i]["score"]!)
            lbContent[i].text = String(i + 1) + " . " + name + " : " + score
        }
    }
    
    func setup() {
        let width       = frame.width
        let height      = frame.height
        let rectHeight  = width / 13
        let marginWidth = CGFloat(30)
        
        // Semi-Opacity Background
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        // Settings Groupbox
        let lbGroup = UIView(frame: CGRect(x:0, y:0, width: width/1.5, height: height/1.5))
        lbGroup.layer.cornerRadius = 10.0
        lbGroup.backgroundColor = UIColor.whiteColor()
        lbGroup.center = self.center
        
        let lbLabel = UILabel(frame: CGRect(x: 0, y: 0, width: lbGroup.frame.width, height: rectHeight))
        lbLabel.text = "Leaderboard"
        lbLabel.textColor = UIColor(hex:0x333333)
        lbLabel.font = UIFont(name: "ChalkboardSE-Bold", size: lbLabel.font.pointSize * 1.2)
        lbLabel.textAlignment = NSTextAlignment.Center
        
        let labelHeightSize = rectHeight * 0.6
        
        let topPlayer = UILabel(frame: CGRect(
            x: marginWidth,
            y: rectHeight * 1.2,
            width: lbGroup.frame.width,
            height: labelHeightSize))
        let sndPlayer = UILabel(frame: CGRect(
            x: marginWidth,
            y: (topPlayer.frame.origin.y + labelHeightSize),
            width: lbGroup.frame.width,
            height: labelHeightSize))
        let thirdPlayer = UILabel(frame: CGRect(
            x: marginWidth,
            y: (sndPlayer.frame.origin.y + labelHeightSize),
            width: lbGroup.frame.width,
            height: labelHeightSize))
        let forthPlayer = UILabel(frame: CGRect(
            x: marginWidth,
            y: (thirdPlayer.frame.origin.y + labelHeightSize),
            width: lbGroup.frame.width,
            height: labelHeightSize))
        let fifthPlayer = UILabel(frame: CGRect(x: marginWidth,
            y: (forthPlayer.frame.origin.y + labelHeightSize),
            width: lbGroup.frame.width,
            height: labelHeightSize))
        lbContent.append(topPlayer)
        lbContent.append(sndPlayer)
        lbContent.append(thirdPlayer)
        lbContent.append(forthPlayer)
        lbContent.append(fifthPlayer)
        
        let lbContentColor = UIColor(hex:0x555555)
        topPlayer.textColor = lbContentColor
        sndPlayer.textColor = lbContentColor
        thirdPlayer.textColor = lbContentColor
        forthPlayer.textColor = lbContentColor
        fifthPlayer.textColor = lbContentColor
        
        let lbContentFont = UIFont(name: "ChalkboardSE-Light", size: topPlayer.font.pointSize * 0.9)
        topPlayer.font = lbContentFont
        sndPlayer.font = lbContentFont
        thirdPlayer.font = lbContentFont
        forthPlayer.font = lbContentFont
        fifthPlayer.font = lbContentFont
        
        exitBtn = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
        exitBtn.backgroundColor = UIColor(hex: 0xF44336)
        exitBtn.setImage(UIImage(named: "icon-exit"), forState: UIControlState.Normal)
        exitBtn.frame.origin.x = lbGroup.frame.width - exitBtn.frame.width
        exitBtn.bounds = CGRectInset(exitBtn.frame, 5.0, 5.0)
        exitBtn.layer.cornerRadius = 10.0
        
        lbGroup.addSubview(lbLabel)
        lbGroup.addSubview(topPlayer)
        lbGroup.addSubview(sndPlayer)
        lbGroup.addSubview(thirdPlayer)
        lbGroup.addSubview(forthPlayer)
        lbGroup.addSubview(fifthPlayer)
        lbGroup.addSubview(exitBtn)
        self.addSubview(lbGroup)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
