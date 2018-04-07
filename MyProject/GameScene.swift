//
//  GameScene.swift
//  MyProject
//
//  Created by Kevin Lee on 3/30/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//


import ARKit

class GameScene: SKScene {
    var sceneView: ARSKView {
        return view as! ARSKView
    }
    
    var isWorldSetUp = false
    var sight: SKSpriteNode!
    
    let gameSize = CGSize(width: 5, height: 5)
    
    /*
    override func didMove(to view: SKView) {
        sight = SKSpriteNode(imageNamed: "sight")
        addChild(sight)
        
        srand48(Int(Date.timeIntervalSinceReferenceDate))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isWorldSetUp {
            setUpWorld()
        }
        
    }*/
    /*
    private func setUpWorld() {
        guard let currentFrame = sceneView.session.currentFrame,
            let scene = SKScene(fileNamed: "Level1")
            else { return }
        
        for node in scene.children {
            if let node = node as? SKSpriteNode {
                var translation = matrix_identity_float4x4
                let positionX = node.position.x / scene.size.width
                let positionY = node.position.y / scene.size.height
                translation.columns.3.x =
                    Float(positionX * gameSize.width)
                translation.columns.3.z =
                    -Float(positionY * gameSize.height)
                translation.columns.3.y = Float(drand48() - 0.5)
                
                let transform =
                    currentFrame.camera.transform * translation
                let anchor = Anchor(transform: transform)
                if let name = node.name,
                    let type = NodeType(rawValue: name) {
                    anchor.type = type
                    sceneView.session.add(anchor: anchor)
                    if anchor.type == .firebug {
                        addBugSpray(to: currentFrame)
                    }
                }
            }
        }
        
        isWorldSetUp = true
    }
    */
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = sight.position
        let hitNodes = nodes(at: location)
        var hitBug: SKNode?
        for node in hitNodes {
            if node.name == NodeType.bug.rawValue ||
                (node.name == NodeType.firebug.rawValue && hasBugspray) {
                hitBug = node
                break
            }
        }
        
        run(Sounds.fire)
        if let hitBug = hitBug,
            let anchor = sceneView.anchor(for: hitBug) {
            let action = SKAction.run {
                self.sceneView.session.remove(anchor: anchor)
            }
            let group = SKAction.group([Sounds.hit, action])
            let sequence = [SKAction.wait(forDuration: 0.3), group]
            hitBug.run(SKAction.sequence(sequence))
        }
        
        hasBugspray = false
    }
    */
}
