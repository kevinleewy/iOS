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
    
    var scene: SCNScene     //main scene
    var creatureScene: SCNScene //creature scene
    var slot: Int = -1
    var attackParticles: SCNNode
    var daeFilename: String
    var soundFilename: String
    var originalScale: Float
    //var animationKey: String
    
    init(name: String, id: String, scene: SCNScene) {
        
        //Load data from JSON
        let jsonResult = JSONData(filename: "json/\(id)").getData()
        self.daeFilename = jsonResult?["scene"] as! String
        
        self.scene = scene
        self.creatureScene = SCNScene(named: daeFilename)!
        self.attackParticles = SCNNode()
        self.attackParticles.geometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.3)
        self.attackParticles.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        self.soundFilename = jsonResult?["sound_file"] as! String
        //self.animationKey = jsonResult?["animation"] as! String
        let oriScale = jsonResult?["scale"] as! NSNumber
        self.originalScale = oriScale.floatValue
        
        super.init()
        self.name = name
        
        NSLog("Master Keys:\(self.creatureScene.rootNode.animationKeys.description)")
        for key in self.creatureScene.rootNode.animationKeys {
            NSLog("Key: \(key)")
            let player = self.creatureScene.rootNode.animationPlayer(forKey: key)
            player?.play()
            NSLog((player?.description)!)
        }

        for childNode in self.creatureScene.rootNode.childNodes {
            //NSLog("Init:Animation Keys:\(childNode.animationKeys.description)")
            for key in childNode.animationKeys {
                NSLog("Key: \(key)")
                let player = childNode.animationPlayer(forKey: key)
                childNode.addAnimationPlayer(player!, forKey: key)
                player?.play()
                NSLog((player?.description)!)
            }
            self.addChildNode(childNode as SCNNode)
            
        }
        
        self.scale = SCNVector3(x: self.originalScale, y: self.originalScale, z: self.originalScale)
        self.opacity = 0.0
        
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    func summon(playSound: Bool){
        //self.runAction(summonAction)
        if playSound {
            self.runAction(SCNAction.group([
                summonAction,
                SCNAction.playAudio(SCNAudioSource(fileNamed: self.soundFilename)!, waitForCompletion: false)
            ]))
        } else {
            self.runAction(summonAction)
        }

        //let anim = SCNAnimation(contentsOf: URL(fileURLWithPath: self.daeFilename))
        //self.addAnimation(anim, forKey: "unnamed animation #0")
        
        NSLog("Master Animation Keys:\(self.animationKeys.description)")
        NSLog("Root Animation Keys:\(self.creatureScene.rootNode.animationKeys.description)")
        for child in self.creatureScene.rootNode.childNodes {
            NSLog("Summon: Animation Keys:\(child.animationKeys.description)")
            
            for key in child.animationKeys {
                NSLog("Summon: Key:\(key)")
                /*let animation = child.animation(forKey: key)!
                animation.repeatCount = 5
                child.removeAnimation(forKey: key)
                child.addAnimation(animation, forKey: key)
 */
            }
        }
    }
    
    func attack(target: SCNCreature, destroyed: Int){
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

        var destroyedAction:SCNAction = SCNAction()
        if destroyed != 0 {
            destroyedAction = SCNAction.sequence([
                SCNAction.fadeOut(duration: 1.0),
                SCNAction.run({node in
                    let creatureNode = node as! SCNCreature
                    let field = node.parent as! SCNField
                    _ = field.removeCreature(slot: creatureNode.slot)
                })
            ])
        }
        
        
        target.runAction(SCNAction.sequence([
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
        
        self.scene.rootNode.addChildNode(newAttackParticles)
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
    }

}
