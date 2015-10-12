//
//  Settings.swift
//  agario
//
//  Created by Yunhan Li on 9/22/15.
//
//

import UIKit

class Settings: UIView {
    var motionDetectSwitch = UISwitch()
    var exitBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let width       = frame.width
        let height      = frame.height
        let rectHeight  = width / 13
        let marginWidth = CGFloat(30)
        
        // Semi-Opacity Background
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        // Settings Groupbox
        let settingsGroup = UIView(frame: CGRect(x:0, y:0, width: width/1.5, height: height/1.5))
        settingsGroup.layer.cornerRadius = 10.0
        settingsGroup.backgroundColor = UIColor.whiteColor()
        settingsGroup.center = self.center
        
        let settingsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: settingsGroup.frame.width, height: rectHeight))
        settingsLabel.text = "Settings"
        settingsLabel.textColor = UIColor(hex:0x333333)
        settingsLabel.font = UIFont(name: "ChalkboardSE-Bold", size: settingsLabel.font.pointSize)
        settingsLabel.textAlignment = NSTextAlignment.Center
        
        let motionDetectorLabel = UILabel(frame: CGRect(x: marginWidth, y: rectHeight * 1.2, width: 0, height: 0))
        motionDetectorLabel.text = "Device Motion Detector"
        motionDetectorLabel.textColor = UIColor(hex:0x333333)
        motionDetectorLabel.sizeToFit()

        motionDetectSwitch = UISwitch(frame: CGRect(x: 0, y: rectHeight * 1.2, width: 0, height: 0))
        motionDetectSwitch.sizeToFit()
        motionDetectSwitch.frame.origin.x = settingsGroup.frame.width - motionDetectSwitch.frame.width - marginWidth
        
        exitBtn = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
        exitBtn.backgroundColor = UIColor(hex: 0xF44336)
        exitBtn.setImage(UIImage(named: "icon-exit"), forState: UIControlState.Normal)
        exitBtn.frame.origin.x = settingsGroup.frame.width - exitBtn.frame.width
        exitBtn.bounds = CGRectInset(exitBtn.frame, 5.0, 5.0)
        exitBtn.layer.cornerRadius = 10.0
        
        settingsGroup.addSubview(settingsLabel)
        settingsGroup.addSubview(motionDetectorLabel)
        settingsGroup.addSubview(motionDetectSwitch)
        settingsGroup.addSubview(exitBtn)
        self.addSubview(settingsGroup)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
