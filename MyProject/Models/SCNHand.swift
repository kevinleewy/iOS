//
//  SCNHand.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNHand: SCNNode {
    
    private var scene: ARSCNView
    private var hand: [SCNCard?]
    static let HAND_WIDTH: Float = 0.4 //40cm
    
    init(config: [Int], scene: ARSCNView) {

        self.scene = scene
        self.hand = []
        
        super.init()
        self.position = SCNVector3(x: 0.0, y: 0.0, z: -0.2)
        for card in config {
            draw(card)
        }
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func draw(_ cardId:Int){
        let cardType: CardType = CardType(rawValue: cardId)!
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
            card?.runAction(SCNAction.move(
                to: SCNVector3(
                    x: left + (1.0 + Float(i)) * gap,
                    y: 0.0,
                    z: 0.001 * Float(i)
                ),
                duration: 1     //1 second
            ))
        }
    }
    
    public func discard(_ slot:Int){
        guard slot >= 0 && slot < self.hand.count else { return }
        let card = self.hand[slot]
        self.hand[slot] = nil
        card?.runAction(SCNAction.fadeOut(duration: 1.0))
        reorganize()
        card?.removeFromParentNode()
    }
    
    public func reorganize(){
        //print("Before: \(self.hand.description)")
        let newHand = self.hand.compactMap { $0 } //remove nil elements
        //print("After: \(newHand.description)")
        self.hand = newHand
        
        //reposition cards in hand
        let gap = SCNHand.HAND_WIDTH / Float(hand.count + 1)
        let left = -SCNHand.HAND_WIDTH / 2
        for (i, card) in hand.enumerated() {
            card?.runAction(SCNAction.move(
                to: SCNVector3(
                    x: left + (1.0 + Float(i)) * gap,
                    y: 0.0,
                    z: 0.001 * Float(i)
                ),
                duration: 1     //1 second
            ))
        }
    }
    
    public func isEmpty() -> Bool {
        return hand.count == 0
    }
    
    public func getSlotFor(card : SCNCard) -> Int? {
        for (i, cardInHand) in hand.enumerated() {
            if card == cardInHand {
                return i
            }
        }
        return nil
    }
    
}
