//
//  GameScene.swift
//  agar-clone
//
//  Created by Ming on 8/24/15.
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

import SpriteKit
import CoreMotion
import MultipeerConnectivity

class GameScene: SKScene {
    
    enum GameMode {
        case SP // Single player
        case MPMaster // Multi player master
        case MPClient // Multi player client
    }
    
    var parentView : GameViewController!
    
    var world : SKNode!
    var foodLayer : SKNode!
    var barrierLayer : SKNode!
    var playerLayer : SKNode!
    var hudLayer : Hud!
    var background : SKSpriteNode!
    var defaultBackgroundColor : UIColor!
    
    var currentPlayer: Player? = nil
    var rank : [Dictionary<String, Any>] = []
    var playerName = ""
    var splitButton : SKSpriteNode!
    var currentMass : SKLabelNode!
    
    var touchingLocation : UITouch? = nil
    var motionManager : CMMotionManager!
    var motionDetectionIsEnabled = false
    var soundDetector : SoundController!
    var soundDetectionIsEnabled = false
    
    // Menus
    var pauseMenu : PauseView!
    var gameOverMenu : GameOverView!
    
    var gameMode : GameMode! = GameMode.SP
    
    // Multipeer variables
    var session : MCSession!
    var clientDelegate : ClientSessionDelegate!
    var masterDelegate : MasterSessionDelegate!
    
    override func didMoveToView(view: SKView) {
        paused = true
        self.view?.multipleTouchEnabled = true
        
        // Prepare multipeer connectivity
        session = MCSession(peer: MCPeerID(displayName: UIDevice.currentDevice().name))
        clientDelegate = ClientSessionDelegate(scene: self, session: session)
        masterDelegate = MasterSessionDelegate(scene: self, session: session)
        
        world = self.childNodeWithName("world")!
        foodLayer = world.childNodeWithName("foodLayer")
        barrierLayer = world.childNodeWithName("barrierLayer")
        playerLayer = world.childNodeWithName("playerLayer")
        background = world.childNodeWithName("//background") as! SKSpriteNode
        defaultBackgroundColor = background.color
        
        /* Setup your scene here */
        world.position = CGPoint(x: CGRectGetMidX(frame),
            y: CGRectGetMidY(frame))
 
        // Setup Hud
        hudLayer = Hud(hudWidth: self.frame.width, hudHeight: self.frame.height)
        self.addChild(hudLayer)
        physicsWorld.contactDelegate = self
        
        // Setup pause menu and death menu
        pauseMenu = PauseView(frame: self.frame, scene: self)
        self.view!.addSubview(pauseMenu)
        gameOverMenu = GameOverView(frame: self.frame, scene: self)
        self.view!.addSubview(gameOverMenu)
        
        // Device motion detector
        motionManager = CMMotionManager()
        
        // Sound Detector
        soundDetector = SoundController()
    }
    
    func cleanAll() {
        foodLayer.removeAllChildren()
        barrierLayer.removeAllChildren()
        playerLayer.removeAllChildren()
        
        self.removeAllActions()
    }
    
    func start(gameMode : GameMode = GameMode.SP) {
        // set background to default color
        self.background.color = self.defaultBackgroundColor
        
        self.gameMode = gameMode
        
        cleanAll()
        
        scheduleRunRepeat(self, time: Double(GlobalConstants.LeaderboardUpdateInterval)) { () -> Void in
            self.updateLeaderboard()
        }
        
        scheduleRunRepeat(self, time: Double(GlobalConstants.PersistentLeaderboardUpdateInterval)) { () -> Void in
            self.parentView.leaderboard.save()
        }
        
        if gameMode == GameMode.SP || gameMode == GameMode.MPMaster {
            // Create Foods
            self.spawnFood(100)
            // Create Barriers
            self.spawnBarrier(15)
            
            scheduleRunRepeat(self, time: Double(GlobalConstants.BarrierRespawnInterval)) { () -> Void in
                if self.barrierLayer.children.count < GlobalConstants.BarrierLimit {
                    self.spawnBarrier()
                }
            }
            
            self.currentPlayer = Player(playerName: playerName, parentNode: self.playerLayer)
        }
        
        // Spawn AI for single player mode
        if gameMode == GameMode.SP {
            for _ in 0..<4 {
                let _ = StupidPlayer(playerName: "Stupid AI", parentNode: self.playerLayer)
            }
            for _ in 0..<4 {
                let _ = AIPlayer(playerName: "Smarter AI", parentNode: self.playerLayer)
            }
        }
        
        if gameMode != GameMode.SP {
            if gameMode == GameMode.MPMaster {
                session.delegate = masterDelegate
                scheduleRunRepeat(self, time: Double(GlobalConstants.BroadcastInterval)) { () -> Void in
                    self.masterDelegate.broadcast()
                }
            }
            if gameMode == GameMode.MPClient {
                session.delegate = clientDelegate
                clientDelegate.requestSpawn()
            }
        }
        
        // Start recording if sound detection is enabled
        if soundDetectionIsEnabled {
            soundDetector.startRecording()
            print("recording")
        }

        scheduleRunRepeat(self, time: Double(GlobalConstants.SoundUpateInterval)) { () -> Void in
            if self.soundDetectionIsEnabled {
                let db = self.soundDetector.update()
                self.changeBackground(db)
            }
        }
        
        self.updateLeaderboard()
        
        paused = false
    }
    
    func pauseGame() {
        self.pauseMenu.hidden = false
        
        // Only pause in SP mode
        if gameMode == GameMode.SP {
            self.paused = true
        }
    }
    
    func continueGame() {
        self.pauseMenu.hidden = true
        self.paused = false
    }
    
    func abortGame() {
        self.soundDetector.stopRecording()
        self.paused = true
        self.pauseMenu.hidden = true
        self.gameOverMenu.hidden = true
        self.parentView.mainMenuView.hidden = false
        
        self.session.disconnect()
    }
    
    func gameOver() {
        if gameMode == GameMode.SP {
            // Pause only in SP mode
            //self.paused = true
        }
        
        self.gameOverMenu.hidden = false
    }
    
    func respawn() {
        self.paused = false
        self.gameOverMenu.hidden = true
        if gameMode == GameMode.SP || gameMode == GameMode.MPMaster {
            if currentPlayer == nil || currentPlayer!.isDead() {
                currentPlayer = Player(playerName: playerName, parentNode: self.playerLayer)
                currentPlayer!.children.first!.position = randomPosition()
            }
        } else {
            // Send request to server
            self.clientDelegate.requestSpawn()
        }
    }
    
    func spawnFood(n : Int = 1) {
        for _ in 0..<n {
            foodLayer.addChild(Food(foodColor: randomColor()))
        }
    }
    
    func spawnBarrier(n : Int = 1) {
        for _ in 0..<n {
            barrierLayer.addChild(Barrier())
        }
    }
    
    func changeBackground(db: Float) {
        if db < -GlobalConstants.minumDecibel {
            background.runAction(SKAction.colorizeWithColor(UIColor(hex:0x30393b), colorBlendFactor: 1.0, duration: 3.0))
        } else {
            let r = background.color.components.red
            let g = background.color.components.green
            let b = background.color.components.blue
            let color = UIColor(red: dbMapToColor(db, color: r), green: dbMapToColor(db, color: g), blue: dbMapToColor(db, color: b),alpha: 1)
            background.runAction(SKAction.colorizeWithColor(color, colorBlendFactor: 1.0, duration: 3.0))
        }
    }
    
    func dbMapToColor(db: Float, color: CGFloat) -> CGFloat{
        return (1 - color) * CGFloat((db + GlobalConstants.minumDecibel) / GlobalConstants.minumDecibel) + color
    }
    
    func updateLeaderboard() {
        rank = []
        for player in playerLayer.children as! [Player] {
            rank.append([
                "name": player.displayName,
                "score": player.totalMass()
            ])
        }
        
        if gameMode == GameMode.SP && currentPlayer != nil { // Only put self score into leaderboard
            self.parentView.leaderboard.updateRank([["name" : currentPlayer!.displayName,
                "score": currentPlayer!.totalMass()]])
        } else {
            self.parentView.leaderboard.updateRank(rank)
        }
        
        rank.sortInPlace({$0["score"] as! CGFloat > $1["score"] as! CGFloat})

        hudLayer.setLeaderboard(rank)
    }
    
    func centerWorldOnPosition(position: CGPoint) {
        let screenLocation = self.convertPoint(position, fromNode: world)
        let screenCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        world.position = world.position - screenLocation + screenCenter
    }
    
    func scaleWorldBasedOnPlayer(player : Player) {
        if player.children.count == 0 || player.totalMass() == 0 {
            world.setScale(1.0)
            return
        }
        let scaleFactorBallNumber = 1.0 + (log(CGFloat(player.children.count)) - 1) * 0.2
        let t = log10(CGFloat(player.totalMass())) - 1
        let scaleFactorBallMass = 1.0 + t * t * 1.0
        world.setScale(1 / scaleFactorBallNumber / scaleFactorBallMass)
    }
    
    func motionDetection() -> CGVector? {
        if let motion = motionManager.deviceMotion {
            //motion.attitude.yaw
            let m = motion.attitude.rotationMatrix
            let x = Vector3D(x: m.m11, y: m.m12, z: m.m13)
            let y = Vector3D(x: m.m21, y: m.m22, z: m.m23)
            let z = Vector3D(x: m.m31, y: m.m32, z: m.m33)
            
            let g = Vector3D(x: 0.0, y: 0.0, z: -1.0)
            let pl = dot(z, rhs: g)
            var d = g - z * pl
            d = d / d.length()
            
            let nd = CGVector(dx: dot(d, rhs: y), dy: -1.0 * dot(d, rhs: x))
            let maxv : CGFloat = 10000.0
            return nd * maxv
        }
        return nil
    }
    
    override func didSimulatePhysics() {

        world.enumerateChildNodesWithName("//ball*", usingBlock: {
            node, stop in
            let ball = node as! Ball
            ball.regulateSpeed()
        })
        
        if let p = currentPlayer {
            centerWorldOnPosition(p.centerPosition())
        } else if playerLayer.children.count > 0 {
            let p = playerLayer.children.first! as! Player
            centerWorldOnPosition(p.centerPosition())
        } else {
            centerWorldOnPosition(CGPoint(x: 0, y: 0))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if paused {
            return
        }
        
        if gameMode == GameMode.MPClient {
            clientDelegate.updateScene()
        }
        
        if gameMode != GameMode.MPClient {
            // Respawn food and barrier
            let fl = gameMode == GameMode.SP ? GlobalConstants.FoodLimit : 250
            let foodRespawnNumber = min(fl - foodLayer.children.count, GlobalConstants.FoodRespawnRate)
            spawnFood(foodRespawnNumber)
        }
        
        if currentPlayer != nil {
            if let t = touchingLocation {
                let p = t.locationInNode(world)
                if gameMode == GameMode.MPClient {
                    clientDelegate.requestMove(p)
                }
                currentPlayer!.move(p)
            } else {
                if gameMode == GameMode.MPClient {
                    clientDelegate.requestFloating()
                }
                currentPlayer!.floating()
            }
            
            let v = motionDetection()
            if motionDetectionIsEnabled && v != nil {
                let c = currentPlayer!.centerPosition()
                let p = CGPoint(x: c.x + v!.dx, y: c.y + v!.dy)
                if gameMode == GameMode.MPClient {
                    clientDelegate.requestMove(p)
                }
                currentPlayer!.move(p)
            }
        } else {
            // Send request to server
        }
        
        for var i = playerLayer.children.count - 1; i >= 0; i-- {
            let p = playerLayer.children[i] as! Player
            p.checkDeath()
        }
        
        if currentPlayer != nil && currentPlayer!.isDead() {
            currentPlayer = nil
            self.gameOver()
        }
        
        for p in playerLayer.children as! [Player] {
            p.refreshState()
        }
        
        if currentPlayer != nil {
            hudLayer.setScore(currentPlayer!.totalMass())
            scaleWorldBasedOnPlayer(currentPlayer!)
        } else if playerLayer.children.count > 0 {
            scaleWorldBasedOnPlayer(playerLayer.children.first! as! Player)
        } else {
            world.setScale(1.0)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count <= 0 || paused {
            return
        }
        
        for touch in touches {
            let screenLocation = touch.locationInNode(self)
            if self.hudLayer.splitBtn.containsPoint(screenLocation) {
                if currentPlayer != nil {
                    currentPlayer!.split()
                    if gameMode == GameMode.MPClient {
                        clientDelegate.requestSplit()
                    }
                }
            } else if self.hudLayer.pauseBtn.containsPoint(screenLocation) {
                self.pauseGame()
            } else {
                touchingLocation = touch
            }
        }
        
        if let t = touchingLocation {
            let screenLocation = t.locationInNode(self)
            if screenLocation.x > frame.width * 0.7 {
                hudLayer.moveSplitButtonToLeft()
            }
            if screenLocation.x < frame.width * 0.3 {
                hudLayer.moveSplitButtonToRight()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count <= 0 || paused {
            return
        }
        
        for touch in touches {
            let screenLocation = touch.locationInNode(self)
            if self.hudLayer.splitBtn.containsPoint(screenLocation) {
            } else {
                touchingLocation = touch
            }
        }
        
        if let t = touchingLocation {
            let screenLocation = t.locationInNode(self)
            if screenLocation.x > frame.width * 0.7 {
                hudLayer.moveSplitButtonToLeft()
            }
            if screenLocation.x < frame.width * 0.3 {
                hudLayer.moveSplitButtonToRight()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count <= 0 || paused {
            return
        }
        
        touchingLocation = nil
    }
}

//Contact Detection
extension GameScene : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        var fstBody : SKPhysicsBody
        var sndBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fstBody = contact.bodyA
            sndBody = contact.bodyB
        } else {
            fstBody = contact.bodyB
            sndBody = contact.bodyA
        }
        
        // Purpose of using "if let" is to test if the object exist
        if let fstNode = fstBody.node {
            if let sndNode = sndBody.node {
                if fstNode.name!.hasPrefix("ball") && sndNode.name!.hasPrefix("barrier") {
                    let nodeA = fstNode as! Ball
                    let nodeB = sndNode as! Barrier
                    if nodeA.radius >= nodeB.radius {
                        if let p = nodeA.parent {
                            nodeA.split(min(4, 16 - p.children.count + 1))
                            sndNode.removeFromParent()
                        }
                    }
                }
                if fstNode.name!.hasPrefix("food") && sndNode.name!.hasPrefix("ball") {
                    let ball = sndNode as! Ball
                    ball.beginContact(fstNode as! Food)
                }
                
                if fstNode.name!.hasPrefix("ball") && sndNode.name!.hasPrefix("ball") {
                    var ball1 = fstNode as! Ball // Big
                    var ball2 = sndNode as! Ball // Small
                    if ball2.mass > ball1.mass {
                        let tmp = ball2
                        ball2 = ball1
                        ball1 = tmp
                    }
                    ball1.beginContact(ball2)
                }
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var fstBody : SKPhysicsBody
        var sndBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            fstBody = contact.bodyA
            sndBody = contact.bodyB
        } else {
            fstBody = contact.bodyB
            sndBody = contact.bodyA
        }
        if let fstNode = fstBody.node {
            if let sndNode = sndBody.node {
                if fstNode.name!.hasPrefix("food") && sndNode.name!.hasPrefix("ball") {
                    let ball = sndNode as! Ball
                    ball.endContact(fstNode as! Food)
                }
                
                if fstNode.name!.hasPrefix("ball") && sndNode.name!.hasPrefix("ball") {
                    var ball1 = fstNode as! Ball // Big
                    var ball2 = sndNode as! Ball // Small
                    if ball2.mass > ball1.mass {
                        let tmp = ball2
                        ball2 = ball1
                        ball1 = tmp
                    }
                    ball1.endContact(ball2)
                }
            }
        }
    }
}