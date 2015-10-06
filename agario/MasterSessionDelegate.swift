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
            
            // Food
            var foodArray : [JSON] = []
            for f in self.scene.foodLayer.children as! [Food] {
                foodArray.append(f.toJSON())
            }
            json["foods"] = JSON(foodArray)
            
            // Players & Balls
            var playerArray : [JSON] = []
            for f in self.scene.playerLayer.children as! [Player] {
                playerArray.append(f.toJSON())
            }
            json["players"] = JSON(playerArray)
            
            do {
                try self.session.sendData(json.rawData(), toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
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
            //print("Sending back spawn info", [peerID])
            // TODO: Check whether or not he is dead
            //let p = Player(playerName: json["name"].stringValue, parentNode: self.scene.playerLayer, initPosition: randomPosition())
            let p = Player(playerName: json["name"].stringValue, parentNode: self.scene.playerLayer, initPosition: CGPoint(x: 0, y: 0))
            let response : JSON = ["type": "SPAWN", "ID": p.name!]
            do {
                try self.session.sendData(response.rawData(), toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable)
            } catch let e as NSError {
                print("Something wrong when sending SPAWN info back", e)
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
}
