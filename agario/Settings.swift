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
    var soundDetectSwitch  = UISwitch()
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
        settingsLabel.font = UIFont(name: "ChalkboardSE-Bold", size: settingsLabel.font.pointSize * 1.2)
        settingsLabel.textAlignment = NSTextAlignment.Center
        
        let motionDetectorLabel = UILabel(frame: CGRect(x: marginWidth, y: rectHeight * 1.2, width: 0, height: 0))
        motionDetectorLabel.text = "Device Motion Detector"
        motionDetectorLabel.font = UIFont(name: "ChalkboardSE-Light", size: motionDetectorLabel.font.pointSize)
        motionDetectorLabel.textColor =  UIColor(hex:0x555555)
        motionDetectorLabel.sizeToFit()
        
        motionDetectSwitch = UISwitch(frame: CGRect(x: 0, y: rectHeight * 1.2, width: 0, height: 0))
        motionDetectSwitch.sizeToFit()
        motionDetectSwitch.frame.origin.x = settingsGroup.frame.width - motionDetectSwitch.frame.width - marginWidth
        
        let soundDetector_posY = rectHeight * 1.2 + motionDetectorLabel.frame.height * 2.2
        let soundDetectorLabel = UILabel(frame: CGRect(x: marginWidth, y: soundDetector_posY, width: 0, height: 0))
        soundDetectorLabel.text = "Device Sound Detector"
        soundDetectorLabel.font = UIFont(name: "ChalkboardSE-Light", size: soundDetectorLabel.font.pointSize)
        soundDetectorLabel.textColor = UIColor(hex:0x555555)
        soundDetectorLabel.sizeToFit()
        
        soundDetectSwitch = UISwitch(frame: CGRect(x: 0, y: soundDetector_posY, width: 0, height: 0))
        soundDetectSwitch.sizeToFit()
        soundDetectSwitch.frame.origin.x = settingsGroup.frame.width - motionDetectSwitch.frame.width - marginWidth
        
        exitBtn = UIButton(frame: CGRect(x:0, y:0, width:40, height:40))
        exitBtn.backgroundColor = UIColor(hex: 0xF44336)
        exitBtn.setImage(UIImage(named: "icon-exit"), forState: UIControlState.Normal)
        exitBtn.frame.origin.x = settingsGroup.frame.width - exitBtn.frame.width
        exitBtn.bounds = CGRectInset(exitBtn.frame, 5.0, 5.0)
        exitBtn.layer.cornerRadius = 10.0
        
        settingsGroup.addSubview(settingsLabel)
        settingsGroup.addSubview(motionDetectorLabel)
        settingsGroup.addSubview(motionDetectSwitch)
        settingsGroup.addSubview(soundDetectorLabel)
        settingsGroup.addSubview(soundDetectSwitch)
        settingsGroup.addSubview(exitBtn)
        self.addSubview(settingsGroup)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
