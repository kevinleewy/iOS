//
//  SCNField.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNField: SCNNode {
    
    private var scene: ARSCNView
    private var creatures: [SCNCreature?]
    static let MAX_CREATURES: Int = 5
    static let CREATURE_CENTROID_GAP: Float = 2.0
    
    init(config: [Any], scene: ARSCNView) {

        self.scene = scene
        self.creatures = [SCNCreature?](repeating: nil, count: SCNField.MAX_CREATURES)
        super.init()
        self.position = SCNVector3(x: 0.0, y: -2.0, z: -2.0)
        for (slot, creatureData) in config.enumerated() {
            if let _ = creatureData as? Int {
                continue
            }
            if let creatureDataObj = creatureData as? [String:Any],
                let creatureId = creatureDataObj["id"] as? Int,
                let strength = creatureDataObj["strength"] as? Int,
                let life = creatureDataObj["life"] as? Int{
                var id: String
                
                switch creatureId {
                    case 0:
                        id = "wolf"
                    case 2:
                        id = "dragon"
                    default:
                        id = "ivysaur"
                }

                let creature = SCNCreature(name: "Ally\(slot)", id: id, strength: strength, life:life, scene: scene)
                if !self.addCreature(creature: creature, slot: slot, playSound: false) {
                    NSLog("Failed to add Ally\(slot)")
                }
            }
        }
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    //returns index of available slot, -1 if there is none
    public func findAvailableCreatureSlot() -> Int {
        for i in 0..<SCNField.MAX_CREATURES {
            if creatures[i] == nil {
                return i
            }
        }
        return -1
    }
    
    //Adds creature to creature slot. Returns true if successful, false otherwise
    public func addCreature(creature: SCNCreature, slot: Int, playSound: Bool) -> Bool {
        
        //return false if slot is out of range or another creature already present at slot
        guard slot >= 0 && slot < SCNField.MAX_CREATURES,
            creatures[slot] == nil else { return false }
        
        creatures[slot] = creature
        creature.slot = slot
        creature.position = SCNVector3(x: -4.0 + SCNField.CREATURE_CENTROID_GAP * Float(slot), y: 0.0, z: 0.0)
        self.addChildNode(creature)
        creature.summon(playSound: false);
        return true
    }
    
    //Removes creature from creature slot. Returns true if successful, false otherwise
    public func removeCreature(slot: Int) -> Bool {
        
        //return false if slot is out of range or no creature at slot
        guard slot >= 0 && slot < SCNField.MAX_CREATURES,
            creatures[slot] != nil else { return false }
        
        let creature = creatures[slot]
        creatures[slot] = nil
        //add creature.disappear()
        creature?.removeFromParentNode()
        return true
    }
    
    public func hasCreatures() -> Bool {
        for creature in creatures {
            if creature != nil{
                return true
            }
        }
        return false
    }
    
    public func getCreature(slot: Int) -> SCNCreature? {
        return creatures[slot]
    }
    
    public func getLeftMostCreature() -> SCNCreature? {
        for creature in creatures {
            if creature != nil {
                return creature
            }
        }
        return nil
    }
    
    public func getCreatures() -> [SCNCreature?] {
        return creatures
    }

}
