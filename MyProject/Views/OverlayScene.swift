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
    
    var announcementNode: SKLabelNode!
    
    var announcement = "" {
        didSet {
            self.announcementNode.text = self.announcement
            self.announcementNode.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.5),
                SKAction.wait(forDuration: ANNOUNCEMENT_DURATION),
                SKAction.fadeOut(withDuration: 0.5)
            ]))
        }
    }
    
    // MARK: Constants
    let ANNOUNCEMENT_DURATION = 2.0 //2 seconds
    
    
    override init(size: CGSize) {
        super.init(size: size)

        self.backgroundColor = UIColor.clear
        
        self.announcementNode = SKLabelNode(text: ":)")
        self.announcementNode.fontName = "DINAlternate-Bold"
        self.announcementNode.fontColor = UIColor.black
        self.announcementNode.fontSize = 24
        self.announcementNode.position = CGPoint(x: size.width/2, y: size.height/2 )
        self.announcementNode.alpha = 0.0
        
        self.addChild(self.announcementNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
