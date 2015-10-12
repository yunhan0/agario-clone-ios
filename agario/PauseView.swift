//
//  PauseView.swift
//  agario
//
//  Created by Ming on 10/4/15.
//
//

import SpriteKit

class PauseView: UIView {
    
    var backButton : UIButton!
    var continueButton : UIButton!
    var scene : GameScene!
    
    init(frame: CGRect, scene: GameScene) {
        super.init(frame: frame)
        self.scene = scene
        setup()
    }
    
    func setup() {
        let width       = frame.width
        let height      = frame.height
        
        self.hidden = true
        
        // Semi-Opacity Background
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        let buttonWidth = width / 5
        let buttonHeight = height / 5
        
        backButton = UIButton(frame: CGRect(x: width / 2 - buttonWidth / 2, y: 3 * height / 4 - buttonHeight / 2,
            width: buttonWidth, height: buttonHeight))
        backButton.setTitle("Quit Game", forState: .Normal)
        backButton.addTarget(scene, action: "abortGame", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        continueButton = UIButton(frame: CGRect(x: width / 2 - buttonWidth / 2, y: height / 4 - buttonHeight / 2,
            width: buttonWidth, height: buttonHeight))
        continueButton.setTitle("Continue", forState: .Normal)
        continueButton.addTarget(scene, action: "continueGame", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(continueButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
