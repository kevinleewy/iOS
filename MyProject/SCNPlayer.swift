//
//  SCNPlayer.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNPlayer: SCNNode {
    
    private var scene: SCNScene
    private var field: SCNField
    private var hand : SCNHand
    private var life : SCNLife
    
    init(config: [String: Any], scene: SCNScene, depth: Float) {
        
        let handConf = config["hand"] as! [Int]
        let fieldConf = config["field"] as! [Int]
        let lifeConf = config["life"] as! Int
        
        self.scene = scene
        self.field = SCNField(config: fieldConf, scene: scene)
        self.hand  = SCNHand(config: handConf, scene: scene)
        self.life  = SCNLife(config: lifeConf, scene: scene)
        super.init()
        self.position = SCNVector3(x: 0.0, y: 0.0, z: depth)
        self.addChildNode(self.field)
        self.addChildNode(self.hand)
        self.addChildNode(self.life)
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
        
    public func getField() -> SCNField {
        return self.field
    }
    
    public func getHand() -> SCNHand {
        return self.hand
    }
    
    public func getLife() -> SCNLife {
        return self.life
    }
    
    public func playCard(cardId:Int, handSlot:Int, fieldSlot:Int){
        
        var id: String
        
        switch cardId {
            case 0:
                id = "wolf"
            default:
                id = "ivysaur"
        }

        hand.discard(handSlot)
        let creature = SCNCreature(name: "Ally\(fieldSlot)", id: id, scene: scene)
        if !field.addCreature(creature: creature, slot: fieldSlot, playSound: true) {
            NSLog("Failed to add Ally\(fieldSlot)")
        }
    }
}
