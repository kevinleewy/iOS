//
//  SKHand.swift
//  MyProject
//
//  Created by Kevin Lee on 4/24/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import SpriteKit
import SocketIO

enum CardLevel :CGFloat {
    case board = 10
    case selected = 100
}

class SKHand: SKScene {
    
    var hand = [SKCard?]()
    var socket: SocketIOClient!
    static let HAND_WIDTH: CGFloat = 400
    
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "bg_blank")
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        addChild(bg)
        /*
        let wolf = SKCard(cardType: .wolf)
        wolf.position = CGPoint(x: 100, y: 100)
        addChild(wolf)
        
        let bear = SKCard(cardType: .bear)
        bear.position = CGPoint(x: 200, y: 100)
        addChild(bear)
        
        let dragon = SKCard(cardType: .dragon)
        dragon.position = CGPoint(x: 300, y: 100)
        addChild(dragon)
 */
    }

    /*
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)           // 1
            if let card = atPoint(location) as? Card {        // 2
                
                if card.enlarged { return }
                
                card.position = location
            }
        }
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? SKCard {
                
                /*
                //Enlarge the card
                if touch.tapCount > 2 {
                    card.enlarge()
                    return
                }
                
                if card.enlarged { return }
                */
                
                //Double tapping the card plays the card
                if touch.tapCount > 1 {
                    for (i, cardInHand) in hand.enumerated() {
                        if card == cardInHand {
                            self.socket.emit("actionSelect", ["action":"play", "handCardSlot": i])
                            return
                        }
                    }
                }
 
                
                card.zPosition = CardLevel.selected.rawValue
                card.removeAction(forKey: "drop")
                card.run(SKAction.scale(to: 1.3, duration: 0.25), withKey: "pickup")
                
                //Start wiggling
                let wiggleIn = SKAction.scaleX(to: 1.0, duration: 0.2)
                let wiggleOut = SKAction.scaleX(to: 1.2, duration: 0.2)
                let wiggle = SKAction.sequence([wiggleIn, wiggleOut])
                card.run(SKAction.repeatForever(wiggle), withKey: "wiggle")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let card = atPoint(location) as? SKCard {
                
                //if card.enlarged { return }
                
                card.zPosition = CardLevel.board.rawValue
                //card.removeFromParent()
                //addChild(card)
                card.removeAction(forKey: "pickup")
                card.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
                
                //Stop wiggling
                card.removeAction(forKey: "wiggle")
            }
        }
    }
    
    public func loadHand(cardIds:[Int], socket: SocketIOClient){
        self.socket = socket
        let gap = SKHand.HAND_WIDTH / CGFloat(cardIds.count + 1)
        let left:CGFloat = 50  //50 pixels from left edge
        for (i, cardId) in cardIds.enumerated() {
            let newCard = SKCard(cardType: CardType.init(rawValue: cardId)!)
            newCard.zPosition = CardLevel.board.rawValue
            newCard.position = CGPoint(x: left + CGFloat(i) * gap, y: 100)
            self.hand.append(newCard)   //add to array
            addChild(newCard)   //add to scene
            newCard.run(SKAction.fadeIn(withDuration: 0.2))
        }
    }
    
    public func destroyHand(){
        for card in self.hand {
            card?.removeFromParent()
        }
        self.hand = [SKCard]()
    }
    
    public func addCard(_ cardId:Int){

        let newCard = SKCard(cardType: CardType.init(rawValue: cardId)!)
        newCard.zPosition = CardLevel.board.rawValue
        newCard.position = CGPoint(x: 1000, y: 100)
        self.hand.append(newCard)   //add to array
        addChild(newCard)   //add to scene
        newCard.run(SKAction.fadeIn(withDuration: 0.2))
        
        reorganize()
    }
    
    public func discard(_ slot:Int){
        guard slot >= 0 && slot < self.hand.count else { return }
        let card = self.hand[slot]
        self.hand[slot] = nil
        card?.run(SKAction.fadeOut(withDuration: 1.0))
        let newHand = self.hand.compactMap { $0 } //remove nil elements
        self.hand = newHand
        reorganize()
        card?.removeFromParent()
    }
    
    public func reorganize(){
        
        //reposition cards in hand
        let gap = SKHand.HAND_WIDTH / CGFloat(hand.count + 1)
        let left:CGFloat = 50  //50 pixels from left edge
        for (i, card) in hand.enumerated() {
            card?.run(SKAction.moveTo(x: left + CGFloat(i) * gap, duration: 1))
        }
    }
}
