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
    
    var scene: ARSCNView     //main scene
    var creatureScene: SCNScene //creature scene
    var slot: Int = -1
    var attackParticles: SCNNode
    var daeFilename: String
    var soundFilename: String
    var originalScale: Float
    var id: String
    var strength: Int
    var life: Int
    var model: SCNNode //model node
    var creatureStatsNode: SCNCreatureStats
    
    //Dragon specific
    var idlePlayer: SCNAnimationPlayer?
    var agroPlayer: SCNAnimationPlayer?
    
    init(name: String, id: String, strength: Int, life: Int ,scene: ARSCNView) {
        
        //Load data from JSON
        let jsonResult = JSONData(filename: "json/\(id)").getData()
        self.daeFilename = jsonResult?["scene"] as! String
        
        self.id = id
        self.strength = strength
        self.life = life
        self.creatureStatsNode = SCNCreatureStats()
        self.creatureStatsNode.constraints?.append(SCNLookAtConstraint(target: scene.pointOfView))
        
        self.scene = scene
        self.creatureScene = SCNScene(named: daeFilename)!
        self.model = SCNNode()
        self.attackParticles = SCNNode()
        self.attackParticles.geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.3)
        self.attackParticles.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        self.soundFilename = jsonResult?["sound_file"] as! String
        self.originalScale = (jsonResult?["scale"] as! NSNumber).floatValue
        
        super.init()
        self.name = name
        
        /*
        NSLog("Master Keys:\(self.creatureScene.rootNode.animationKeys.description)")
        for key in self.creatureScene.rootNode.animationKeys {
            NSLog("Key: \(key)")
            let player = self.creatureScene.rootNode.animationPlayer(forKey: key)
            player?.play()
            NSLog((player?.description)!)
        }
        */

        if id == "dragon" {
            //let idleDae = jsonResult?["idle"] as! String
            //let idleScene = SCNScene(named: idleDae)!
            //NSLog("ChildNodes:\(idleScene.rootNode.childNodes.description)")
            //NSLog("AnimationKeys:\(idleScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationKeys.description)")
            self.idlePlayer = self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationPlayer(forKey: "animation1")
            
            let flyDae = jsonResult?["fly"] as! String
            let flyScene = SCNScene(named: flyDae)!
            self.agroPlayer = flyScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationPlayer(forKey: "animation1")
            self.agroPlayer?.stop()
            self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.addAnimationPlayer(self.agroPlayer!, forKey: "fly")
            
        }
        if id == "wolf" {
            self.idlePlayer = self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.childNode(withName: "root", recursively: false)?.animationPlayer(forKey: "animation1")
        }
        
        for childNode in self.creatureScene.rootNode.childNodes {
            self.model.addChildNode(childNode as SCNNode)
        }
        
        self.model.scale = SCNVector3(x: self.originalScale, y: self.originalScale, z: self.originalScale)
        self.model.opacity = 0.0
        self.addChildNode(self.model)
        self.addChildNode(self.creatureStatsNode)
        
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    func summon(playSound: Bool){
        //self.runAction(summonAction)
        if playSound {
            self.model.runAction(SCNAction.group([
                summonAction,
                SCNAction.playAudio(SCNAudioSource(fileNamed: self.soundFilename)!, waitForCompletion: false)
            ]))
        } else {
            self.model.runAction(summonAction)
        }

        //let anim = SCNAnimation(contentsOf: URL(fileURLWithPath: self.daeFilename))
        //self.addAnimation(anim, forKey: "unnamed animation #0")
        /*
        NSLog("Master Animation Keys:\(self.animationKeys.description)")
        NSLog("Root Animation Keys:\(self.creatureScene.rootNode.animationKeys.description)")
        for child in self.creatureScene.rootNode.childNodes {
            NSLog("Summon: Animation Keys:\(child.animationKeys.description)")
            
            for key in child.animationKeys {
                NSLog("Summon: Key:\(key)")
                let animation = child.animation(forKey: key)!
                animation.repeatCount = 5
                child.removeAnimation(forKey: key)
                child.addAnimation(animation, forKey: key)
 
            }
        }*/
    }
    
    func attack(target: SCNCreature, destroyed: Bool){
        let newAttackParticles = self.attackParticles.clone()
        newAttackParticles.transform = self.worldTransform
        newAttackParticles.transform.m42 += 0.3 //raise height by 30cm
        let targetTransform = target.worldTransform
        let targetPosition = SCNVector3(targetTransform.m41, targetTransform.m42+0.3, targetTransform.m43)
        
        self.scene.scene.rootNode.addChildNode(newAttackParticles)
        
        if self.id == "dragon" {
            self.runAction(SCNAction.sequence([
                SCNAction.run({node in
                    self.idlePlayer?.stop()
                    self.agroPlayer?.play()
                }),
                SCNAction.wait(duration: 7.55),
                SCNAction.run({node in
                    self.agroPlayer?.stop()
                    self.idlePlayer?.play()
                })
            ]))
        }
        
        newAttackParticles.runAction(SCNAction.sequence([
            SCNAction.fadeIn(duration: 0.5),
            SCNAction.move(to: targetPosition, duration: 2),
            SCNAction.fadeOut(duration: 0.5),
            SCNAction.removeFromParentNode()
        ]))

        var destroyedAction:SCNAction = SCNAction()
        if destroyed {
            destroyedAction = SCNAction.sequence([
                SCNAction.fadeOut(duration: 1.0),
                SCNAction.run({node in
                    let creatureNode = node.parent as! SCNCreature
                    let field = creatureNode.parent as! SCNField
                    _ = field.removeCreature(slot: creatureNode.slot)
                })
            ])
        }
        
        
        target.model.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.5),
            SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 0.5),
            destroyedAction
        ]))
    }
    
    func attackPlayer(target: SCNPlayer, damage: Int){
        let newAttackParticles = self.attackParticles.clone()
        newAttackParticles.transform = self.worldTransform
        newAttackParticles.transform.m42 += 0.3 //raise height by 30cm
        let targetTransform = target.worldTransform
        let targetPosition = SCNVector3(targetTransform.m41, targetTransform.m42, targetTransform.m43)
        
        self.scene.scene.rootNode.addChildNode(newAttackParticles)
        newAttackParticles.runAction(SCNAction.sequence([
            SCNAction.fadeIn(duration: 0.5),
            SCNAction.move(to: targetPosition, duration: 2),
            SCNAction.fadeOut(duration: 0.5),
            SCNAction.removeFromParentNode()
            ]))

        target.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.5),
            SCNAction.run({node in
                let playerNode = node as! SCNPlayer
                playerNode.loseLife(amount: damage)
            })
        ]))
        
        if self.id == "dragon" {
            self.runAction(SCNAction.sequence([
                SCNAction.run({node in
                    self.idlePlayer?.stop()
                    self.agroPlayer?.play()
                }),
                SCNAction.wait(duration: 7.55),
                SCNAction.run({node in
                    self.agroPlayer?.stop()
                    self.idlePlayer?.play()
                })
            ]))
        }
    }

}
