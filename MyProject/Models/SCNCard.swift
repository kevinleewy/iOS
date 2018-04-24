//
//  SCNCard.swift
//  MyProject
//
//  Created by Kevin Lee on 3/31/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

enum CardType :Int {
    case wolf,
    bear,
    dragon,
    ivysaur
}

enum CardState :Int {
    case faceDownPortrait,
    faceDownLandscape,
    faceUpPortrait,
    faceUpLandscape
}

enum CardLocation :Int {
    case void,
    deck,
    hand,
    field,
    graveyard,
    expelled
}

class SCNCard : SCNNode {
    
    //Class Constants
    private static let CARD_WIDTH: CGFloat = 0.05
    private static let CARD_HEIGHT: CGFloat = 0.08
    
    //Instance Constants
    let cardType :CardType
    let frontTexture :SKTexture
    let backTexture :SKTexture
    let textureFilename :String
    let largeTextureFilename :String
    let soundFilename :String
    
    //Instance Properties
    //var damage = 0
    //let damageLabel :SKLabelNode
    var state: CardState = .faceUpPortrait
    var location: CardLocation = .void
    var largeTexture :SKTexture?
    
    //var enlarged = false
    //var savedPosition = CGPoint.zero

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(cardType: CardType) {
        self.cardType = cardType
        self.backTexture = SKTexture(imageNamed: "card_back")
        
        switch cardType {
            case .wolf:
                self.textureFilename = "card_creature_wolf"
                self.largeTextureFilename = "card_creature_wolf_large"
                self.soundFilename = "wolf_howl.wav"
            case .bear:
                self.textureFilename = "card_creature_bear"
                self.largeTextureFilename = "card_creature_bear_large"
                self.soundFilename = "bear_growl.wav"
            case .dragon:
                self.textureFilename = "card_creature_dragon"
                self.largeTextureFilename = "card_creature_dragon_large"
                self.soundFilename = "dragon-roar.wav"
            case .ivysaur:
                self.textureFilename = "card_creature_ivysaur"
                self.largeTextureFilename = "card_creature_ivysaur_large"
                self.soundFilename = "ivysaur.mp3"
        }
        
        frontTexture = SKTexture(imageNamed: self.textureFilename)
        
        /*
         damageLabel = SKLabelNode(fontNamed: "OpenSans-Bold")
        damageLabel.name = "damageLabel"
        damageLabel.fontSize = 12
        damageLabel.fontColor = SKColor(red: 0.47, green: 0.0, blue: 0.0, alpha: 1.0)
        damageLabel.text = "0"
        damageLabel.position = CGPoint(x: 25, y: 40)
        */
        
        super.init()
        switch cardType {
            case .wolf:
                self.name = "Wolf"
            case .bear:
                self.name = "Bear"
            case .dragon:
                self.name = "Dragon"
            case .ivysaur:
                self.name = "Ivysaur"
        }
        
        self.geometry = SCNPlane(width: SCNCard.CARD_WIDTH, height: SCNCard.CARD_HEIGHT)
        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.textureFilename)// frontTexture
        
        let cardBack = SCNNode()
        cardBack.geometry = SCNPlane(width: SCNCard.CARD_WIDTH, height: SCNCard.CARD_HEIGHT)
        cardBack.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "card_back")//backTexture
        cardBack.eulerAngles = SCNVector3(0, 180.degreesToRadians, 0)
        addChildNode(cardBack)
        
        //addChild(damageLabel)
    }
    
    init(cardName: String) {
        switch cardName {
            case "Wolf":
                self.cardType = .wolf
            case "Bear":
                self.cardType = .bear
            case "Dragon":
                self.cardType = .dragon
            case "Ivysaur":
                self.cardType = .ivysaur
            default:
                self.cardType = .dragon     //temporary
        }
        self.backTexture = SKTexture(imageNamed: "card_back")
        
        let data = JSONData(filename: cardName).getData()
        
        self.textureFilename = data?["card_image"] as! String
        self.largeTextureFilename = data?["large_card_image"] as! String
        self.soundFilename = data?["sound_file"] as! String
        
        frontTexture = SKTexture(imageNamed: self.textureFilename)
        
        super.init()
        self.name = data?["name"] as? String
        
        
        /*
         //card labels
         damageLabel = SKLabelNode(fontNamed: "OpenSans-Bold")
         damageLabel.name = "damageLabel"
         damageLabel.fontSize = 12
         damageLabel.fontColor = SKColor(red: 0.47, green: 0.0, blue: 0.0, alpha: 1.0)
         damageLabel.text = "0"
         damageLabel.position = CGPoint(x: 25, y: 40)
         addChild(damageLabel)
         */
        
        
        //card front
        self.geometry = SCNPlane(width: SCNCard.CARD_WIDTH, height: SCNCard.CARD_HEIGHT)
        self.geometry?.firstMaterial?.diffuse.contents = UIImage(named: self.textureFilename)// frontTexture
        
        //card back
        let cardBack = SCNNode()
        cardBack.geometry = SCNPlane(width: SCNCard.CARD_WIDTH, height: SCNCard.CARD_HEIGHT)
        cardBack.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "card_back")//backTexture
        cardBack.eulerAngles = SCNVector3(0, 180.degreesToRadians, 0)
        addChildNode(cardBack)
    }
    
    //Flips a card face-up if it's face-down, and vice versa
    func flip() {
        guard self.location == .field else { return }
        let flipAngle: CGFloat
        switch self.state {
            case .faceDownLandscape:
                self.state = .faceUpLandscape
                flipAngle  = -180.degreesToRadians
            case .faceDownPortrait:
                self.state = .faceUpPortrait
                flipAngle  = -180.degreesToRadians
            case .faceUpLandscape:
                self.state = .faceDownLandscape
                flipAngle  = 180.degreesToRadians
            case .faceUpPortrait:
                self.state = .faceDownPortrait
                flipAngle  = 180.degreesToRadians
        }
        self.runAction(SCNAction.rotateBy(x: 0, y: flipAngle, z: 0, duration: 1))
    }
    
    func tap() {
        guard self.location == .field else { return }
        let tapAngle: CGFloat
        switch self.state {
            case .faceDownLandscape:
                self.state = .faceDownPortrait
                tapAngle = 90.degreesToRadians
            case .faceDownPortrait:
                self.state = .faceDownLandscape
                tapAngle = -90.degreesToRadians
            case .faceUpLandscape:
                self.state = .faceUpPortrait
                tapAngle = 90.degreesToRadians
            case .faceUpPortrait:
                self.state = .faceUpLandscape
                tapAngle = -90.degreesToRadians
        }
        self.runAction(SCNAction.rotateBy(x: 0, y: 0, z: tapAngle, duration: 1))
    }
    
}
