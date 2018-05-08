//
//  SCNPlayer.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNPlayer: SCNNode {
    
    private var id: String
    private var scene: ARSCNView
    private var field: SCNField
    private var hand : SCNHand
    private var sceneLife : SCNLife
    private var life: Int {
        didSet {
            self.playerStatsNode.lifeNode.text = "\(self.life)"
        }
    }
    private var deckSize: Int {
        didSet {
            self.playerStatsNode.deckNode.text = "\(self.deckSize)"
        }
    }
    private var playerStatsNode: SKPlayerStats
    
    init(config: [String: Any], scene: ARSCNView, depth: Float) {
        
        self.id = config["id"] as! String
        let handConf = config["hand"] as! [Int]
        let fieldConf = config["field"] as! [Any]
        self.life = config["life"] as! Int
        self.deckSize = config["deck"] as! Int
        
        self.scene = scene
        self.field = SCNField(config: fieldConf, scene: scene)
        self.hand  = SCNHand(config: handConf, scene: scene)
        self.sceneLife  = SCNLife(config: self.life, scene: scene)
        
        self.playerStatsNode = SKPlayerStats(id: self.id, life: self.life, deck: deckSize)
        
        super.init()
        self.position = SCNVector3(x: 0.0, y: 0.0, z: depth)
        self.addChildNode(self.field)
        self.addChildNode(self.hand)
        self.addChildNode(self.sceneLife)
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func getField() -> SCNField {
        return self.field
    }
    
    public func getHand() -> SCNHand {
        return self.hand
    }
    
    public func getLife() -> Int {
        return self.life
    }
    
    public func loseLife(amount: Int) {
        self.life -= amount
        self.sceneLife.loseLife(amount: amount)
    }
    
    public func gainLife(amount: Int) {
        self.life += amount
        self.sceneLife.gainLife(amount: amount)
    }
    
    public func getSceneLife() -> SCNLife {
        return self.sceneLife
    }
    
    public func getStats() -> SKPlayerStats {
        return self.playerStatsNode
    }
    
    public func playCard(handSlot slot:Int){
        hand.discard(slot)
    }
    
    public func draw(_ cardId:Int){
        self.deckSize -= 1
        self.hand.draw(cardId)
    }
    
    public func summonCreature(cardId:Int, fieldSlot:Int){
        var id: String
        
        switch cardId {
            case 0:
                id = "wolf"
            case 2:
                id = "dragon"
            default:
                id = "ivysaur"
        }
        let creature = SCNCreature(name: "\(self.id)\(fieldSlot)", id: id, strength: 1, life: 1, scene: scene)
        if !field.addCreature(creature: creature, slot: fieldSlot, playSound: true) {
            NSLog("Failed to add Ally\(fieldSlot)")
        }
    }
}
