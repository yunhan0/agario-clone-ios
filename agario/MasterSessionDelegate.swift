//
//  MasterSessionDelegate.swift
//  agario
//
//  Created by Ming on 10/4/15.
//
//

import SpriteKit
import MultipeerConnectivity

class MasterSessionDelegate : NSObject, MCSessionDelegate {
    
    var scene : GameScene!
    var session : MCSession!
    
    var userDict : Dictionary<MCPeerID, String> = Dictionary<MCPeerID, String>()
    
    // A hack to improve performance
    var foodMask : Int = 0
    
    init(scene : GameScene, session : MCSession) {
        self.scene = scene
        self.session = session
    }
    
    func broadcast() {
        if self.session.connectedPeers.count == 0 {
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            var json : JSON = ["type": "BROADCAST"]
            
            // Food & a hack to improve performance
            if self.foodMask == 0 {
                var foodArray : [JSON] = []
                for f in self.scene.foodLayer.children as! [Food] {
                    foodArray.append(f.toJSON())
                }
                json["foods"] = JSON(foodArray)
            }
            self.foodMask = (self.foodMask + 1) % 4
            
            // Players & Balls
            var playerArray : [JSON] = []
            for f in self.scene.playerLayer.children as! [Player] {
                playerArray.append(f.toJSON())
            }
            json["players"] = JSON(playerArray)
            
            // Barriers
            var barrierArray : [JSON] = []
            for f in self.scene.barrierLayer.children as! [Barrier] {
                barrierArray.append(f.toJSON())
            }
            json["barriers"] = JSON(barrierArray)
            
            do {
                try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            } catch let e as NSError {
                print(e)
            }
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
        //print("Got something in master\n", json)
        if json["type"].stringValue == "SPAWN" {
            dispatch_async(dispatch_get_main_queue(), {
                let p = Player(playerName: json["name"].stringValue, parentNode: self.scene.playerLayer, initPosition: randomPosition())
                let response : JSON = ["type": "SPAWN", "ID": p.name!]
                self.userDict[peerID] = p.name!
                do {
                    try self.session.sendData(response.rawData(), toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable)
                } catch let e as NSError {
                    print("Something wrong when sending SPAWN info back", e)
                }
            })

//            let p = Player(playerName: json["name"].stringValue, parentNode: self.scene.playerLayer, initPosition: randomPosition())
//            let response : JSON = ["type": "SPAWN", "ID": p.name!]
//            userDict[peerID] = p.name!
//            do {
//                try self.session.sendData(response.rawData(), toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable)
//            } catch let e as NSError {
//                print("Something wrong when sending SPAWN info back", e)
//            }
        }
        if json["type"].stringValue == "MOVE" {
            let p : CGPoint = CGPoint(x: json["x"].doubleValue, y: json["y"].doubleValue)
            if let nm = userDict[peerID] {
                if let nd = scene.playerLayer.childNodeWithName(nm) {
                    let player = nd as! Player
                    dispatch_async(dispatch_get_main_queue(), {
                        player.move(p)
                    })
                    //player.move(p)
                }
            }
        }
        if json["type"].stringValue == "FLOATING" {
            if let nm = userDict[peerID] {
                if let nd = scene.playerLayer.childNodeWithName(nm) {
                    let player = nd as! Player
                    dispatch_async(dispatch_get_main_queue(), {
                        player.floating()
                    })
                    //player.floating()
                }
            }
        }
        if json["type"].stringValue == "SPLIT" {
            if let nm = userDict[peerID] {
                if let nd = scene.playerLayer.childNodeWithName(nm) {
                    let player = nd as! Player
                    dispatch_async(dispatch_get_main_queue(), {
                        player.split()
                    })
                    //player.split()
                }
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
}
