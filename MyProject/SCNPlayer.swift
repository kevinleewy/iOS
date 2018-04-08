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
    
    init(scene: SCNScene, depth: Float) {
        self.scene = scene
        self.field = SCNField(scene: scene)
        self.hand  = SCNHand(scene: scene)
        self.life  = SCNLife(scene: scene)
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
}
