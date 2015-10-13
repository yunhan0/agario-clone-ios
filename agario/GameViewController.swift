//
//  GameViewController.swift
//  agar-clone
//
//  Created by Ming on 8/24/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

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

class GameViewController: UIViewController, UITextFieldDelegate, MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate {
    
    var mainMenuView : Menu!
    var settings : Settings!
    var lbView : LeaderboardView!
    var gameView : SKView!
    var scene : GameScene!
    
    // Multipeer part
    var browser : MCBrowserViewController!
    var advertiser : MCAdvertiserAssistant!
    
    // Leaderboard data
    var leaderboard : PersistentLeaderboard!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load persistent leaderboard
        if let l = NSKeyedUnarchiver.unarchiveObjectWithFile(PersistentLeaderboard.ArchiveURL.path!) {
            self.leaderboard = l as! PersistentLeaderboard
        } else {
            self.leaderboard = PersistentLeaderboard()
        }
        
        // Main menu view set up
        mainMenuView = Menu(frame: UIScreen.mainScreen().bounds)
        mainMenuView.startBtn.addTarget(self, action: "startSingle", forControlEvents: .TouchUpInside)
        mainMenuView.multiPlayerBtn.addTarget(self, action: "startMultiple", forControlEvents: .TouchUpInside)
        mainMenuView.scoreBtn.addTarget(self, action: "showLeaderboard", forControlEvents: .TouchUpInside)
        mainMenuView.settingBtn.addTarget(self, action: "showSetting", forControlEvents: .TouchUpInside)
        mainMenuView.nameField.delegate = self
        self.view.addSubview(mainMenuView)
        
        // Setting view set up
        settings = Settings(frame: UIScreen.mainScreen().bounds)
        settings.exitBtn.addTarget(self, action: "exitSetting", forControlEvents: .TouchUpInside)
        settings.motionDetectSwitch.addTarget(self, action: Selector("checkMotionDetectStatus:"), forControlEvents: UIControlEvents.ValueChanged)
        settings.soundDetectSwitch.addTarget(self, action: Selector("checkSoundDetectStatus:"), forControlEvents: UIControlEvents.ValueChanged)
        settings.hidden = true
        
        // Leaderboard view set up
        lbView = LeaderboardView(frame: UIScreen.mainScreen().bounds)
        lbView.exitBtn.addTarget(self, action: "exitLeaderboard", forControlEvents: .TouchUpInside)
        lbView.hidden = true
        
        mainMenuView.addSubview(settings)
        mainMenuView.addSubview(lbView)
        
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
            
            scene.parentView = self
        }
        self.view.insertSubview(gameView, belowSubview: mainMenuView)
        
        // Multipeer init
        self.browser = MCBrowserViewController(serviceType: "agario-ming", session: self.scene.session)
        self.browser.modalPresentationStyle = .FormSheet
        self.browser.maximumNumberOfPeers = 1
        self.browser.delegate = self
        self.advertiser = MCAdvertiserAssistant(serviceType: "agario-ming", discoveryInfo: nil, session: self.scene.session)
        self.advertiser.delegate = self
    }
    
    func startSingle() {
        self.advertiser.stop()
        
        // Set Player Name
        self.scene.playerName = mainMenuView.nameField.text!
        self.mainMenuView.hidden = true
        self.scene.start()
    }
    
    func startMultiple() {
        self.scene.playerName = mainMenuView.nameField.text!
        self.advertiser.stop()
        
        let alert = UIAlertController(title: "New Game or Existent Game", message: "Please make a decision", preferredStyle: .ActionSheet)
        let masterAction = UIAlertAction(title: "Start a New Game", style: .Default) { (action) in
            self.mainMenuView.hidden = true
            self.scene.start(GameScene.GameMode.MPMaster)
            self.advertiser.start()
            alert.dismissViewControllerAnimated(false, completion: { () -> Void in})
        }
        alert.addAction(masterAction)
        let clientAction = UIAlertAction(title: "Search & Join a Game", style: .Default) { [unowned self, browser = self.browser] (action) in
            self.presentViewController(browser, animated: true, completion: nil)
            alert.dismissViewControllerAnimated(false, completion: { () -> Void in})
        }
        alert.addAction(clientAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alert.dismissViewControllerAnimated(false, completion: nil)
        }
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        self.mainMenuView.hidden = true
        self.scene.start(GameScene.GameMode.MPClient)
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        browser.session.disconnect()
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func showSetting() {
        settings.hidden = false
    }
    
    func exitSetting() {
        settings.hidden = true
    }

    func showLeaderboard() {
        lbView.hidden = false
        let l = leaderboard.getRank()
        lbView.setLeaderboardContent(l)
        print(l)
    }
    
    func exitLeaderboard() {
        lbView.hidden = true
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
    
    func checkSoundDetectStatus(sdswitch: UISwitch) {
        if sdswitch.on {
            self.scene.soundDetectionIsEnabled = true
        } else {
            self.scene.soundDetectionIsEnabled = false
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