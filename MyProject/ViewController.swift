//
//  ViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 3/30/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var isWorldSetUp = false
    
    var player1: SCNPlayer?
    var player2: SCNPlayer?
    
    //var creatures: [SCNCreature] = []
    //var hand: [SCNCard] = []
    /*
    func loadDae(name: String) -> SCNNode {
        
        guard let scene = SCNScene(named: name) else {
            NSLog("Unable to load \(name)")
            return SCNNode()
        }
        
        let node = SCNNode()
        for childNode in scene.rootNode.childNodes {
            node.addChildNode(childNode as SCNNode)
        }
        return node
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
        
        //sight = SKSpriteNode(imageNamed: "sight")
        //self.sceneView.scene.rootNode.
        //self.sceneView.session.add(anchor: ARAnchor() addChild(sight)
        
    }
    
    func setUpWorld(){
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        //ship.position = SCNVector3(x: 0, y: -0.5, z: -3)
        //ship.eulerAngles = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
        //ship.opacity = 0.0
        //ship.transform = camera.transform
        
        //self.player1 = scene.rootNode.childNode(withName: "player1", recursively: true)!
        //self.player2 = scene.rootNode.childNode(withName: "player2", recursively: true)!
        
        self.player1 = SCNPlayer(scene: scene, depth: 0.0)
        scene.rootNode.addChildNode(self.player1!)
        
        self.player2 = SCNPlayer(scene: scene, depth: -10.0)    //10 meters deep
        self.player2?.eulerAngles = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
        scene.rootNode.addChildNode(self.player2!)
        
        var field: SCNField = self.player1!.getField()
        for i in 0...4 {
            let creature = SCNCreature(name: "Ally\(i)", daeFilename: "art.scnassets/ivysaur/ivysaur.dae", scene: scene)
            if !field.addCreature(creature: creature, slot: i) {
                NSLog("Failed to add Ally\(i)")
            }
        }
        
        field = self.player2!.getField()
        for i in 0...4 {
            let creature = SCNCreature(name: "Enemy\(i)", daeFilename: "art.scnassets/ivysaur/ivysaur.dae", scene: scene)
            if !field.addCreature(creature: creature, slot: i) {
                NSLog("Failed to add Enemy\(i)")
            }
        }
        /*
        creatures = []
        
        for i in 0...4 {
            creatures.append(Creature(name: "Ally\(i)", x: -4.0 + 2.0 * Float(i), ownerIsMe: true))
        }
        
        for i in 0...4 {
            creatures.append(Creature(name: "Enemy\(i)", x: -4.0 + 2.0 * Float(i), ownerIsMe: false))
        }
        
        for i in 0...9 {
            creatures[i].summon(scene: scene)
        }
        */
        //Build hand
        //Card(cardType: .wolf)
        //hand.append(.wolf)
        //hand.append(.bear)
        //hand.append(.dragon)
        
        //for (i, card) in hand.enumerated() {
        //    let cardNode = Card(cardType: card, x: -0.1 + 0.1 * Float(i))
        //    scene.rootNode.addChildNode(cardNode)
        //}
        /*
        let wolf = loadDae(name: "art.scnassets/wolf/wolf.dae")
        wolf.name = "wolf"
        wolf.position = SCNVector3(x: -2, y: -0.5, z: -3)
        wolf.eulerAngles = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
        wolf.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        wolf.opacity = 0.0
        scene.rootNode.addChildNode(wolf)
        
        let ivysaur = loadDae(name: "art.scnassets/ivysaur/ivysaur.dae")
        ivysaur.name = "ivysaur"
        ivysaur.position = SCNVector3(x: 2, y: -0.5, z: -1)
        //ivysaur.eulerAngles = SCNVector3(0.degreesToRadians, 0.degreesToRadians, 0.degreesToRadians)
        //ivysaur.scale = SCNVector3(x: 1, y: 1, z: 1)
        ivysaur.opacity = 0.0
        scene.rootNode.addChildNode(ivysaur)
        
        let plane = SCNNode()
        plane.geometry = SCNPlane(width: 0.2, height: 0.2)
        plane.geometry?.firstMaterial?.specular.contents = UIColor.orange
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        plane.position = SCNVector3(x: 0, y: 0, z: -1)
        plane.eulerAngles = SCNVector3(90.degreesToRadians, 0.degreesToRadians, 0.degreesToRadians)
        scene.rootNode.addChildNode(plane)
        
        let plane2 = SCNNode()
        plane2.geometry = SCNPlane(width: 0.2, height: 0.2)
        plane2.geometry?.firstMaterial?.specular.contents = UIColor.orange
        plane2.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        plane2.position = SCNVector3(x: 2, y: 0, z: -1)
        plane2.eulerAngles = SCNVector3(90.degreesToRadians, 0.degreesToRadians, 0.degreesToRadians)
        scene.rootNode.addChildNode(plane2)
        
        let helloText = SCNText(string: "Hello", extrusionDepth: 1)
        let helloNode = SCNNode(geometry: helloText)
        helloText.firstMaterial?.diffuse.contents = UIColor.purple
        helloNode.position = SCNVector3(x: -5, y: 0.2, z: -5)
        scene.rootNode.addChildNode(helloNode)
        
        let appearAction = SCNAction.group([SCNAction.fadeIn(duration: 2), SCNAction.move(by: SCNVector3(x: 0, y: 0.2, z: 0), duration: 2)])
        
        ship.runAction(appearAction)
        wolf.runAction(appearAction)
        ivysaur.runAction(appearAction)
        */
    }
    
    func restartSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    /*
    func draw() {
        let cardType: CardType = CardType(rawValue: Int(arc4random_uniform(3)))!
        let newCard: Card = Card(cardType: cardType)
        newCard.opacity = 0
        newCard.position = SCNVector3(x: 0.5, y: 0.0, z: -0.2)
        hand.append(newCard)
        self.sceneView.scene.rootNode.addChildNode(newCard)
        
        newCard.runAction(SCNAction.fadeIn(duration: 0.2))
        
        //reposition cards in hand
        for (i, card) in hand.enumerated() {
            let gap = 0.4/Float(hand.count + 1)
            card.runAction(SCNAction.move(to: SCNVector3(x: -0.2+(1.0+Float(i))*gap, y: 0.0, z: -0.2+0.001*Float(i)), duration: 1))
        }
        
    }*/
    
    @IBAction func summonAction(_ sender: Any) {
        if isWorldSetUp {
            restartSession()
        } else {
            setUpWorld()
        }
        
        isWorldSetUp = !isWorldSetUp
    }
    
    @IBAction func drawAction(_ sender: Any) {
        NSLog("Drawing a card")
        self.player1!.getHand().draw()
        //draw()
    }
    
    @IBAction func AttackAction(_ sender: Any) {
        NSLog((self.sceneView.session.currentFrame?.camera.transform.columns.3.debugDescription)!)
        self.player1!.getField().getCreature(slot: 0)?.attack(target: self.player2!.getField().getCreature(slot: 1)!)
        self.player2!.getField().getCreature(slot: 0)?.attack(target: self.player1!.getField().getCreature(slot: 2)!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Set debug options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        // Run the view's session
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
