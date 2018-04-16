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

    init(life: Int, deck: Int) {
        self.lifeNode = SKLabelNode(text: "Life: \(life)")
        self.lifeNode.fontName = "DINAlternate-Bold"
        self.lifeNode.fontColor = UIColor.black
        self.lifeNode.fontSize = 24
        self.lifeNode.position = CGPoint(x: 0, y: 0)
        
        self.deckNode = SKLabelNode(text: "Deck: \(deck)")
        self.deckNode.fontName = "DINAlternate-Bold"
        self.deckNode.fontColor = UIColor.black
        self.deckNode.fontSize = 24
        self.deckNode.position = CGPoint(x: 0, y: -40)
        
        super.init()
        
        self.addChild(self.lifeNode)
        self.addChild(self.deckNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
