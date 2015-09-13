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
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    var mainMenuView : UIView!
    var gameView : SKView!
    var scene : GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.mainScreen().bounds.width;
        let height = UIScreen.mainScreen().bounds.height;
        
        // Main menu view set up
        
        let buttonWidth = width / 6;
        self.mainMenuView = UIView(frame: UIScreen.mainScreen().bounds)
        mainMenuView.opaque = false
        mainMenuView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        let startButton = UIButton(frame: CGRect(
            x: (width - buttonWidth) / 2, y: (height - buttonWidth) / 2,
            width: buttonWidth, height: buttonWidth));
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.backgroundColor = UIColor.greenColor()
        
        startButton.addTarget(self, action: "startSingle", forControlEvents: .TouchUpInside)
        
        mainMenuView.addSubview(startButton)
        
        self.view.addSubview(mainMenuView);
        
        // Game view set up
        
        self.gameView = SKView(frame: UIScreen.mainScreen().bounds)

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.gameView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            self.scene = scene
        }
        self.view.insertSubview(gameView, belowSubview: mainMenuView)
    }
    
    func startSingle() {
        self.mainMenuView.hidden = true
        self.scene.start()
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
