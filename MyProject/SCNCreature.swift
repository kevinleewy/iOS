//
//  SCNCreature.swift
//  MyProject
//
//  Created by Kevin Lee on 3/31/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNCreature: SCNNode {
    
    let summonAction = SCNAction.group([SCNAction.fadeIn(duration: 2), SCNAction.move(by: SCNVector3(x: 0, y: 0.2, z: 0), duration: 2)])
    let myDepth: Float = -2.0
    let opponentDepth: Float = -8.0
    let myOri: SCNVector3 = SCNVector3(0.degreesToRadians, 0.degreesToRadians, 0.degreesToRadians)
    let opponentOri: SCNVector3 = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
    
    var scene: SCNScene
    var attackParticles: SCNNode
    
    init(name: String, daeFilename: String, scene: SCNScene) {
        
        self.scene = scene
        self.attackParticles = SCNNode()
        self.attackParticles.geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.3)
        self.attackParticles.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        
        super.init()
        self.name = name
        
        //daeFilename = "art.scnassets/ivysaur/ivysaur.dae"
        guard let scene = SCNScene(named: daeFilename) else {
            NSLog("Unable to load creature")
            return
        }
    
        for childNode in scene.rootNode.childNodes {
            self.addChildNode(childNode as SCNNode)
        }
        
        //let depth = ownerIsMe ? myDepth : opponentDepth
        //self.eulerAngles = ownerIsMe ? myOri : opponentOri
        //self.position = SCNVector3(x: x, y: -2, z: depth)
        self.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        self.opacity = 0.0
        
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    func summon(){
        self.runAction(summonAction)
    }
    
    func attack(target: SCNCreature){
        let newAttackParticles = self.attackParticles.clone()
        newAttackParticles.transform = self.worldTransform
        newAttackParticles.transform.m42 += 0.3 //raise height by 30cm
        let targetTransform = target.worldTransform
        let targetPosition = SCNVector3(targetTransform.m41, targetTransform.m42+0.3, targetTransform.m43)
        
        self.scene.rootNode.addChildNode(newAttackParticles)
        newAttackParticles.runAction(SCNAction.sequence([
            SCNAction.fadeIn(duration: 0.5),
            SCNAction.move(to: targetPosition, duration: 2),
            SCNAction.fadeOut(duration: 0.5),
            SCNAction.removeFromParentNode()
        ]))
        target.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.5),
            SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 0.5)
        ]))
    }

}
