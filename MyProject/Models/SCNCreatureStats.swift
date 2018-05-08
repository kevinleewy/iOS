//
//  SCNCreatureStats.swift
//  MyProject
//
//  Created by Kevin Lee on 4/28/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class SCNCreatureStats : SCNNode {
    
    //Class Constants
    private static let WIDTH: CGFloat = 0.20
    private static let HEIGHT: CGFloat = 0.20
    
    var strength: SKLabelNode!
    var life: SKLabelNode!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(){
        super.init()
        self.geometry = SCNPlane(width: SCNCreatureStats.WIDTH, height: SCNCreatureStats.HEIGHT)
        //self.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.geometry?.firstMaterial?.diffuse.contents = SKPlayerStats(id: "", life: 2, deck: 2)
        self.position = SCNVector3(x: 0.0, y: 2.0, z: 0.0)
        //self.addChildNode(<#T##child: SCNNode##SCNNode#>)

    }
}
