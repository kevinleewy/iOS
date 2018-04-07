//
//  SCNHand.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNHand: SCNNode {
    
    private var scene: SCNScene
    private var hand: [SCNCard]
    static let HAND_WIDTH: Float = 0.4 //40cm
    
    init(scene: SCNScene) {
        self.scene = scene
        self.hand = []
        super.init()
        self.position = SCNVector3(x: 0.0, y: 0.0, z: -2.0)
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func draw(){
        let cardType: CardType = CardType(rawValue: Int(arc4random_uniform(3)))!
        let newCard: SCNCard = SCNCard(cardType: cardType)
        newCard.opacity = 0
        newCard.position = SCNVector3(x: 0.5, y: 0.0, z: 0.0)
        hand.append(newCard)
        self.addChildNode(newCard)
        
        newCard.runAction(SCNAction.fadeIn(duration: 0.2))
        
        //reposition cards in hand
        let gap = SCNHand.HAND_WIDTH / Float(hand.count + 1)
        let left = -SCNHand.HAND_WIDTH / 2
        for (i, card) in hand.enumerated() {
            card.runAction(SCNAction.move(
                to: SCNVector3(
                    x: left + (1.0 + Float(i)) * gap,
                    y: 0.0,
                    z: 0.001 * Float(i)
                ),
                duration: 1     //1 second
            ))
        }
    }
    
    public func reorganize(){
        self.hand = self.hand.compactMap { $0 } //remove nil elements
        
        //reposition cards in hand
        let gap = SCNHand.HAND_WIDTH / Float(hand.count + 1)
        let left = -SCNHand.HAND_WIDTH / 2
        for (i, card) in hand.enumerated() {
            card.runAction(SCNAction.move(
                to: SCNVector3(
                    x: left + (1.0 + Float(i)) * gap,
                    y: 0.0,
                    z: 0.001 * Float(i)
                ),
                duration: 1     //1 second
            ))
        }
    }
    
}
