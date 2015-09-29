//
//  GameViewController.swift
//  agar-clone
//
//  Created by Ming on 8/24/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, UITextFieldDelegate {
    
    var mainMenuView : Menu!
    var settings : Settings!
    var gameView : SKView!
    var scene : GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Main menu view set up
        mainMenuView = Menu(frame: UIScreen.mainScreen().bounds)
        mainMenuView.startBtn.addTarget(self, action: "startSingle", forControlEvents: .TouchUpInside)
        mainMenuView.settingBtn.addTarget(self, action: "openSetting", forControlEvents: .TouchUpInside)
        mainMenuView.nameField.delegate = self
        self.view.addSubview(mainMenuView)
        
        // Setting view set up
        settings = Settings(frame: UIScreen.mainScreen().bounds)
        settings.exitBtn.addTarget(self, action: "exitSetting", forControlEvents: .TouchUpInside)
        settings.motionDetectSwitch.addTarget(self, action: Selector("checkMotionDetectStatus:"), forControlEvents: UIControlEvents.ValueChanged)
        settings.hidden = true
        mainMenuView.addSubview(settings)
        
        // Game view set up
        self.gameView = SKView(frame: UIScreen.mainScreen().bounds)

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.gameView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            self.scene = scene
        }
        self.view.insertSubview(gameView, belowSubview: mainMenuView)
    }
    
    func startSingle() {
        // Set Player Name
        self.scene.playerName = mainMenuView.nameField.text!
        self.mainMenuView.hidden = true
        self.scene.start()
    }

    func openSetting() {
        settings.hidden = false
    }
    
    func exitSetting() {
        settings.hidden = true
    }
    
    func checkMotionDetectStatus(mdswitch: UISwitch) {
        if mdswitch.on {
            self.scene.motionManager.startDeviceMotionUpdates()
            self.scene.motionDetectionIsEnabled = true
        } else {
            self.scene.motionManager.stopDeviceMotionUpdates()
            self.scene.motionDetectionIsEnabled = false
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /********************** UITextFieldDelegate Functions **********************/
    // Dismiss keyboard on pressing return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Check the maximum length of textfield
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textLength = (textField.text!.utf16).count + (string.utf16).count - range.length
        return textLength <= GlobalConstants.MaxNameLength
    }
}