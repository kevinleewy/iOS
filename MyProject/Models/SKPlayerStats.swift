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
    
    init(id: String, life: Int, deck: Int) {
        
        let bg1 = SKSpriteNode(imageNamed: "stone_board")
        bg1.position = CGPoint(x: 20, y: -10)
        bg1.size = CGSize(width: 115, height: 115)
        
        let bg2 = SKSpriteNode(imageNamed: "wooden_board")
        bg2.position = CGPoint(x: 20, y: -10)
        bg2.size = CGSize(width: 100, height: 100)
        
        let idNode = SKLabelNode(text: "\(id)")
        idNode.fontName = "DINAlternate-Bold"
        idNode.fontColor = UIColor.black
        idNode.fontSize = 20
        idNode.position = CGPoint(x: 20, y: 10)
        
        let lifeIcon = SKSpriteNode(imageNamed: "heart_icon")
        lifeIcon.position = CGPoint(x: 0, y: -10)
        lifeIcon.size = CGSize(width: 20, height: 20)
        let deckIcon = SKSpriteNode(imageNamed: "deck_icon")
        deckIcon.position = CGPoint(x: 0, y: -40)
        deckIcon.size = CGSize(width: 20, height: 20)
        
        self.lifeNode = SKLabelNode(text: "\(life)")
        self.lifeNode.fontName = "DINAlternate-Bold"
        self.lifeNode.fontColor = UIColor.black
        self.lifeNode.fontSize = 24
        self.lifeNode.position = CGPoint(x: 40, y: -20)
        
        self.deckNode = SKLabelNode(text: "\(deck)")
        self.deckNode.fontName = "DINAlternate-Bold"
        self.deckNode.fontColor = UIColor.black
        self.deckNode.fontSize = 24
        self.deckNode.position = CGPoint(x: 40, y: -50)
        
        super.init()
        
        self.addChild(bg1)
        self.addChild(bg2)
        self.addChild(idNode)
        self.addChild(lifeIcon)
        self.addChild(self.lifeNode)
        self.addChild(deckIcon)
        self.addChild(self.deckNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
