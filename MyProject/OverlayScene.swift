//
//  OverlayScene.swift
//  MyProject
//
//  Created by Kevin Lee on 4/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit
import SpriteKit

class OverlayScene: SKScene {
    
    //var p1LifeNode: SKSpriteNode!
    var p1LifeNode: SKLabelNode!
    var p2LifeNode: SKLabelNode!
    
    var p1Life = 3 {
        didSet {
            self.p1LifeNode.text = "Life: \(self.p1Life)"
        }
    }
    
    var p2Life = 3 {
        didSet {
            self.p2LifeNode.text = "Life: \(self.p1Life)"
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)

        self.backgroundColor = UIColor.clear
        
        self.p1LifeNode = SKLabelNode(text: "Life: 3")
        self.p1LifeNode.fontName = "DINAlternate-Bold"
        self.p1LifeNode.fontColor = UIColor.black
        self.p1LifeNode.fontSize = 24
        self.p1LifeNode.position = CGPoint(x: size.width-100, y: 130 )
        
        self.p2LifeNode = SKLabelNode(text: "Life: 3")
        self.p2LifeNode.fontName = "DINAlternate-Bold"
        self.p2LifeNode.fontColor = UIColor.black
        self.p2LifeNode.fontSize = 24
        self.p2LifeNode.position = CGPoint(x: 80, y: size.height - 80 )
        
        self.addChild(self.p1LifeNode)
        self.addChild(self.p2LifeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
