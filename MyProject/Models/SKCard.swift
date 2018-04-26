//
//  SKCard.swift
//  MyProject
//
//  Created by Kevin Lee on 4/24/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import SpriteKit

class SKCard : SKSpriteNode {
    let cardType :CardType
    let frontTexture :SKTexture
    
    //var damage = 0
    //let damageLabel :SKLabelNode
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(cardType: CardType) {
        self.cardType = cardType
        
        switch cardType {
        case .wolf:
            frontTexture = SKTexture(imageNamed: "card_creature_wolf")
        case .bear:
            frontTexture = SKTexture(imageNamed: "card_creature_bear")
        case .dragon:
            frontTexture = SKTexture(imageNamed: "card_creature_dragon")
        case .ivysaur:
            frontTexture = SKTexture(imageNamed: "card_creature_ivysaur")
        }
        /*
        damageLabel = SKLabelNode(fontNamed: "OpenSans-Bold")
        damageLabel.name = "damageLabel"
        damageLabel.fontSize = 12
        damageLabel.fontColor = SKColor(red: 0.47, green: 0.0, blue: 0.0, alpha: 1.0)
        damageLabel.text = "0"
        damageLabel.position = CGPoint(x: 25, y: 40)
        */
        //super.init(texture: frontTexture, color: UIColor.clear, size: frontTexture.size())
        
        super.init(texture: frontTexture, color: UIColor.clear, size: CGSize(width: 100, height: 140))
        
        //addChild(damageLabel)
    }
    
}
