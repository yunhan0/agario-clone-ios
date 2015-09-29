//
//  Menu.swift
//  agario
//
//  Created by Yunhan Li on 9/19/15.
//
//

import UIKit

class Menu: UIView {
    var nameField      = UITextField()
    var startBtn       = UIButton()
    var multiPlayerBtn = UIButton()
    var scoreBtn       = UIButton()
    var settingBtn     = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let width       = frame.width
        let height      = frame.height
        let rectWidth   = width / 3
        let rectHeight  = width / 13
        let squareWidth = width / 13

        self.opaque = false
        self.backgroundColor = UIColor(patternImage: UIImage(named: "pattern")!)
        
        // Player Name TextField
        nameField = UITextField(frame: CGRect(
            x: (width - rectWidth) / 2, y: (height - rectWidth) / 2,
            width: rectWidth, height: rectHeight))
        nameField.layer.borderWidth = 1
        nameField.layer.cornerRadius = 10.0
        nameField.placeholder = "Nickname"
        // Change keyboard "Return" key to "Done" key
        nameField.returnKeyType = UIReturnKeyType.Done
        // Disable text auto correction
        nameField.autocorrectionType = UITextAutocorrectionType.No
        
        // Single Player Start Button
        startBtn = UIButton(frame: CGRect(
            x: (width - rectWidth) / 2, y: nameField.frame.origin.y + (rectHeight * 1.5),
            width: rectWidth, height: rectHeight));
        startBtn.setTitle("Start Game", forState: .Normal)
        startBtn.backgroundColor = UIColor(hex: 0x2196F3)
        startBtn.layer.cornerRadius = 10.0
        
        // Multiplayer Start Button
        multiPlayerBtn = UIButton(frame: CGRect(
            x: (width - rectWidth) / 2, y: startBtn.frame.origin.y + (rectHeight * 1.5),
            width: rectWidth, height: rectHeight))
        multiPlayerBtn.setTitle("Multiple Player", forState: .Normal)
        multiPlayerBtn.backgroundColor = UIColor(hex: 0x2196F3)
        multiPlayerBtn.layer.cornerRadius = 10.0
        
        // Leaderboard Button
        scoreBtn = UIButton(frame: CGRect(
            x: 0, y: multiPlayerBtn.frame.origin.y,
            width: squareWidth, height: rectHeight))
        scoreBtn.setImage(UIImage(named: "icon-info"), forState: UIControlState.Normal)
        scoreBtn.backgroundColor = UIColor(hex: 0x2196F3)
        scoreBtn.bounds = CGRectInset(scoreBtn.frame, 5.0, 5.0)
        scoreBtn.layer.cornerRadius = 10.0
        
        // Settings Button
        settingBtn = UIButton(frame: CGRect(
            x: (width - squareWidth), y: multiPlayerBtn.frame.origin.y,
            width: squareWidth, height: rectHeight))
        settingBtn.backgroundColor = UIColor(hex: 0x2196F3)
        settingBtn.setImage(UIImage(named: "icon-settings"), forState: UIControlState.Normal)
        settingBtn.bounds = CGRectInset(settingBtn.frame, 5.0, 5.0)
        settingBtn.layer.cornerRadius = 10.0
        
        self.addSubview(startBtn)
        self.addSubview(multiPlayerBtn)
        self.addSubview(scoreBtn)
        self.addSubview(settingBtn)
        self.addSubview(nameField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}