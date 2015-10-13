//
//  ClientSessionDelegate.swift
//  agario
//
//  Created by Ming on 10/4/15.
//
//

import SpriteKit
import MultipeerConnectivity

class ClientSessionDelegate : NSObject, MCSessionDelegate {
    
    var scene : GameScene!
    var session : MCSession!
    var clientID : String? = nil
    var newestBroadcast : JSON? = nil
    
    // Special optimization for food
    var foodSet = Set<String>()
    
    init(scene : GameScene, session : MCSession) {
        self.scene = scene
        self.session = session
    }
    
    
    // NETWORK
    func requestSpawn() {
        if self.session.connectedPeers.count <= 0 {
            return
        }
        //print("Request spawn")
        let json : JSON = ["type": "SPAWN", "name": self.scene.playerName]
        do {
            try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers,
                withMode: MCSessionSendDataMode.Reliable)
        } catch let e as NSError {
            // Do something
            print("Something wrong")
            print(e)
        }
    }
    
    func requestMove(position : CGPoint) {
        if self.session.connectedPeers.count <= 0 {
            return
        }
        let json : JSON = ["type" : "MOVE", "x" : Double(position.x), "y": Double(position.y)]
        do {
            try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
        } catch let e as NSError {
            print(e)
        }
    }
    
    func requestSplit() {
        if self.session.connectedPeers.count <= 0 {
            return
        }
        let json : JSON = ["type" : "SPLIT"]
        do {
            try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let e as NSError {
            print(e)
        }
    }
    
    func requestFloating() {
        if self.session.connectedPeers.count <= 0 {
            return
        }
        let json : JSON = ["type" : "FLOATING"]
        do {
            try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
        } catch let e as NSError {
            print(e)
        }
    }
    
    func updateScene() {
        if let json = newestBroadcast {
            
            // Special optimization for Food layer
            if json["foods"].count > 0 {
                var newids = Set<String>()
                for (_, subjson):(String, JSON) in json["foods"] {
                    let nm = subjson["name"].stringValue
                    newids.insert(nm)
                    if !foodSet.contains(nm) {
                        let fd = Food(foodColor: subjson["color"].intValue)
                        fd.name = nm
                        fd.position.x = CGFloat(subjson["x"].double!)
                        fd.position.y = CGFloat(subjson["y"].double!)
                        self.scene.foodLayer.addChild(fd)
                        self.foodSet.insert(nm)
                    }
                }
                for nd in self.scene.foodLayer.children {
                    if !newids.contains(nd.name!) {
                        nd.removeFromParent()
                        foodSet.remove(nd.name!)
                    }
                }
            }
            
            // Player layer synchronization
            updateLayer(scene.playerLayer, array: json["players"], handler: {(node : SKNode?, playerJSON) -> Void in
                var ballLayer : Player? = nil
                if let nd = node {
                    ballLayer = (nd as! Player)
                } else {
                    // New player
                    let player : Player = Player(playerName: playerJSON["displayName"].stringValue, parentNode: self.scene.playerLayer)
                    player.name = playerJSON["name"].stringValue
                    player.removeAllChildren()
                    
                    ballLayer = player
                }
                
                if let layer = ballLayer {
                    self.updateLayer(layer, array: playerJSON["balls"], handler: { (node : SKNode?, ballJSON) -> Void in
                        let p = CGPoint(x: CGFloat(ballJSON["x"].doubleValue),
                            y: CGFloat(ballJSON["y"].doubleValue))
                        let v = CGVector(dx: CGFloat(ballJSON["dx"].doubleValue),
                            dy: CGFloat(ballJSON["dy"].doubleValue))
                        let td = CGVector(dx: CGFloat(ballJSON["tdx"].doubleValue),
                            dy: CGFloat(ballJSON["tdy"].doubleValue))
                        if let nd = node { // Update ball
                            let ball = nd as! Ball
                            ball.targetDirection = td
                            ball.physicsBody!.velocity = v
                            //ball.position = p
                            
                            // Simple interpolation
                            let newv : CGVector = p - ball.position
                            let newvl = newv.length()
                            if newvl > ball.radius * 1.5 {
                                ball.position = p
                            } else {
                                ball.physicsBody!.velocity = v + newv.normalize() * (min(newvl, ball.radius) / ball.radius * ball.maxVelocity)
                            }
                            
                            let ms = CGFloat(ballJSON["mass"].doubleValue)
                            if ball.mass != ms {
                                ball.setMass(ms)
                                ball.drawBall()
                            }
                        } else { // New ball
                            let ball = Ball(ballName: ballJSON["ballName"].stringValue, ballColor: ballJSON["color"].intValue, ballMass: CGFloat(ballJSON["mass"].doubleValue), ballPosition: p)
                            ball.targetDirection = td
                            ball.name = ballJSON["name"].stringValue
                            ball.physicsBody!.velocity = v
                            layer.addChild(ball)
                        }
                    })
                }
            })
            
            self.updateLayer(self.scene.barrierLayer, array: json["barriers"], handler: { (node : SKNode?, json) -> Void in
                if let _ = node {
                    // Wont need any change
                } else {
                    let br = Barrier()
                    br.name = json["name"].stringValue
                    br.position.x = CGFloat(json["x"].double!)
                    br.position.y = CGFloat(json["y"].double!)
                    self.scene.barrierLayer.addChild(br)
                }
            })
            
            if let nm = clientID {
                if self.scene.currentPlayer == nil || self.scene.currentPlayer!.name != nm {
                    self.scene.currentPlayer = scene.playerLayer.childNodeWithName(nm) as! Player?   
                }
            }
            
            newestBroadcast = nil
        }
    }
    
    func updateLayer(layer : SKNode, array : JSON, handler: (SKNode?, JSON) -> Void) {
        var newids = Set<String>()
        for (_, subjson):(String, JSON) in array {
            newids.insert(subjson["name"].stringValue)
        }
        // Remove dead node
        for var i = layer.children.count - 1; i >= 0; i-- {
            let nd : SKNode = layer.children[i]
            if !newids.contains(nd.name!) {
                nd.removeFromParent()
                nd.removeAllChildren()
            }
        }
        
        // Update rest nodes and insert nodes
        for (_, subjson):(String, JSON) in array {
            let nm = subjson["name"].stringValue
            let nd = layer.childNodeWithName(nm)
            handler(nd, subjson)
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let json = JSON(data: data)
        //print("Got something in client: ", json)
        if json["type"].stringValue == "SPAWN" {
            print("Got feedback: ", json["ID"].stringValue)
            if json["ID"].stringValue != "" {
                self.clientID = json["ID"].stringValue
            }
        }
        if json["type"].stringValue == "BROADCAST" {
            newestBroadcast = json
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        if state == MCSessionState.Connected {
        }
        if state == MCSessionState.NotConnected {
            // A black hack to check whether this bebavious is expected
            if self.scene.parentView.mainMenuView.hidden == false {
                return
            }
            
            print("Connection to server is broken");
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "Error", message: "Connection to the server is broken", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Quit Game", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.scene.abortGame()
                }))
                self.scene.parentView.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
}
