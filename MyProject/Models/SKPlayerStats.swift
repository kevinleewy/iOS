//
//  SKPlayerStats.swift
//  MyProject
//
//  Created by Kevin Lee on 4/16/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SKPlayerStats: SKNode {

    var lifeNode: SKLabelNode!
    var deckNode: SKLabelNode!
    var lifeIcon: SKSpriteNode!
    var deckIcon: SKSpriteNode!

    init(life: Int, deck: Int) {
        
        self.lifeIcon = SKSpriteNode(imageNamed: "heart_icon")
        self.lifeIcon.position = CGPoint(x: 0, y: 10)
        self.lifeIcon.size = CGSize(width: 20, height: 20)
        self.deckIcon = SKSpriteNode(imageNamed: "deck_icon")
        self.deckIcon.position = CGPoint(x: 0, y: -30)
        self.deckIcon.size = CGSize(width: 20, height: 20)
        
        self.lifeNode = SKLabelNode(text: "\(life)")
        self.lifeNode.fontName = "DINAlternate-Bold"
        self.lifeNode.fontColor = UIColor.black
        self.lifeNode.fontSize = 24
        self.lifeNode.position = CGPoint(x: 40, y: 0)
        
        self.deckNode = SKLabelNode(text: "\(deck)")
        self.deckNode.fontName = "DINAlternate-Bold"
        self.deckNode.fontColor = UIColor.black
        self.deckNode.fontSize = 24
        self.deckNode.position = CGPoint(x: 40, y: -40)
        
        super.init()
        
        self.addChild(self.lifeIcon)
        self.addChild(self.lifeNode)
        self.addChild(self.deckIcon)
        self.addChild(self.deckNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
