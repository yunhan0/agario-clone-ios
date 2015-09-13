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
        
        let rectWidth = width / 3;
        let rectHeight = width / 13;
        let squareWidth = width / 13;
        self.mainMenuView = UIView(frame: UIScreen.mainScreen().bounds)
        mainMenuView.opaque = false
        mainMenuView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)

        let nameField = UITextField(frame: CGRect(
            x: (width - rectWidth) / 2, y: (height - rectWidth) / 2,
            width: rectWidth, height: rectHeight))
        nameField.layer.borderWidth = 1
        nameField.layer.cornerRadius = 10.0
        nameField.placeholder = "Nickname"
        
        let startButton = UIButton(frame: CGRect(
            x: (width - rectWidth) / 2, y: nameField.frame.origin.y + (rectHeight * 1.5),
            width: rectWidth, height: rectHeight));
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.backgroundColor = UIColor.greenColor()
        startButton.layer.cornerRadius = 10.0
        startButton.addTarget(self, action: "startSingle", forControlEvents: .TouchUpInside)
        
        let multiPlayerBtn = UIButton(frame: CGRect(
            x: (width - rectWidth) / 2, y: startButton.frame.origin.y + (rectHeight * 1.5),
            width: rectWidth, height: rectHeight))
        multiPlayerBtn.setTitle("Multiple Player", forState: .Normal)
        multiPlayerBtn.backgroundColor = UIColor.greenColor()
        multiPlayerBtn.layer.cornerRadius = 10.0
        
        let scoreBtn = UIButton(frame: CGRect(
            x: 0, y: multiPlayerBtn.frame.origin.y,
            width: squareWidth, height: rectHeight))
        scoreBtn.setTitle("i", forState: .Normal)
        scoreBtn.backgroundColor = UIColor.greenColor()
        scoreBtn.bounds = CGRectInset(scoreBtn.frame, 5.0, 5.0)
        scoreBtn.layer.cornerRadius = 10.0
        
        let aboutBtn = UIButton(frame: CGRect(
            x: (width - squareWidth), y: multiPlayerBtn.frame.origin.y,
            width: squareWidth, height: rectHeight))
        aboutBtn.setTitle("?", forState: .Normal)
        aboutBtn.backgroundColor = UIColor.greenColor()
        aboutBtn.bounds = CGRectInset(aboutBtn.frame, 5.0, 5.0)
        aboutBtn.layer.cornerRadius = 10.0
        
        mainMenuView.addSubview(startButton)
        mainMenuView.addSubview(multiPlayerBtn)
        mainMenuView.addSubview(scoreBtn)
        mainMenuView.addSubview(aboutBtn)
        mainMenuView.addSubview(nameField)
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
