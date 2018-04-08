//
//  SCNLife.swift
//  MyProject
//
//  Created by Holly Liang on 4/7/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNLife: SCNNode {
    
    private var life: Int
    private var scene: SCNScene
    private var icons: [SCNNode]
    
    static let INITIAL_LIFE: Int = 3
    static let ICON_GAP: Float = 0.6 //40cm
    
    init(scene: SCNScene) {
        self.scene = scene
        life = SCNLife.INITIAL_LIFE
        
        self.icons = []
        super.init()
        var pos = -SCNLife.ICON_GAP * Float(SCNLife.INITIAL_LIFE - 1)/2
        for _ in 0..<SCNLife.INITIAL_LIFE {
            let icon = SCNNode()
            icon.geometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.2)
            icon.geometry?.firstMaterial?.diffuse.contents = UIColor.magenta
            icon.position = SCNVector3(x: pos, y: 0.0, z: 0.0)
            icon.opacity = 1.0
            icons.append(icon)
            pos += SCNLife.ICON_GAP
            self.addChildNode(icon)
        }
        self.position = SCNVector3(x: 0.0, y: 0.5, z: -1.0)
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func loseLife(amount: Int) {
        self.life = max(0, self.life-amount)
        for i in stride(from: SCNLife.INITIAL_LIFE, to: self.life, by: -1) {
            self.icons[i-1].runAction(SCNAction.fadeOut(duration: 1.0))
        }
    }
    
    public func gainLife(amount: Int) {
        self.life = min(SCNLife.INITIAL_LIFE, self.life+amount)
        for i in stride(from: self.life, to: SCNLife.INITIAL_LIFE, by: 1) {
            self.icons[i].runAction(SCNAction.fadeOut(duration: 1.0))
        }
    }
    
}

