//
//  ViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 3/30/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit
import SocketIO

// Struct for parsed JSON data ------------------------------------
/*
struct NewsAPIStruct:Decodable {
    let headlines:[Headlines];
}

struct Headlines:Decodable {
    let newsgroupID:Int;
    let newsgroup: String;
    let headline: String;
    
    init (json: [String: Any]) {
        newsgroupID = json ["newsgroupID"] as? Int ?? -1;
        newsgroup = json ["newsgroup"] as? String ?? "";
        headline = json ["headline"] as? String ?? "";
    };
};

struct GameState:Decodable {
    let gameID: Int;
    let newsgroup: String;
    let headline: String;
    
    init (json: [String: Any]) {
        gameID = json ["gameID"] as? Int ?? -1;
        newsgroup = json ["newsgroup"] as? String ?? "";
        headline = json ["headline"] as? String ?? "";
    };
};
*/
class ViewController: UIViewController, ARSCNViewDelegate {

    var spriteScene: OverlayScene!
    
    @IBOutlet weak var connectButton: UIButton!
    
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var drawButton: UIButton!
    
    @IBOutlet weak var attackButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    let trayLauncher = TrayLauncher()
    var isWorldSetUp = false
    var turn = true;
    
    var playerId: String?
    
    var player1: SCNPlayer?
    var player2: SCNPlayer?
    
    var manager: SocketManager?
    var socket: SocketIOClient!
    var host: String = ""
    
    var DEBUG = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //self.sceneView.showsStatistics = true
        
        // Set up spotlight attached to camera
        attachSpotLight()
        
        // Establish connection with server
        connectToServer()
        
    }
    
    func debugprint(_ s:String){
        if self.DEBUG {
            print("DEBUG: \(s)")
        }
    }
    
    func attachSpotLight(){
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 60
        spotLight.spotOuterAngle = 60
        let spotNode = SCNNode()
        spotNode.light = spotLight
        self.sceneView.pointOfView?.addChildNode(spotNode)
    }
    
    func connectToServer() {
        
        DispatchQueue.main.async {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Connecting to Server", message: "Input IP of server", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                //textField.text = "192.168.1.110"  //home
                textField.text = "192.168.17.221"   //work
                //textField.text = "10.30.151.51" //stanford
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Player 1", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.host = (textField?.text)!
                self.playerId = "Player1"
                self.initSocket()   //initialize sockets
            }))
            
            alert.addAction(UIAlertAction(title: "Player 2", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.host = (textField?.text)!
                self.playerId = "Player2"
                self.initSocket()   //initialize sockets
            }))
            
            // TODO: Spectator option
            /*
            alert.addAction(UIAlertAction(title: "Spectator", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.host = (textField?.text)!
                self.playerId = "Spectator"
                self.initSocket()   //initialize sockets
            }))
             */
            
            // 4. Present the alert.
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func initSocket(){
        self.manager = SocketManager(socketURL: URL(string: "http://\(self.host):8080")!,config: [.log(false),.connectParams(["token": playerId!])])
        self.socket = manager?.defaultSocket
        self.setSocketEvents()
        self.socket.connect()
    }
    
    func setUpWorld(config: [String: Any]){
        
        debugprint("Setting up world")
        debugprint(config.description)
        let p1conf = config["player1"] as! [String: Any]
        let p2conf = config["player2"] as! [String: Any]
        let turnPlayer = config["turnPlayer"] as! String
        
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Load Overlay Scene
        self.spriteScene = OverlayScene(size: self.view.bounds.size)
        self.sceneView.overlaySKScene = self.spriteScene
        
        self.player1 = SCNPlayer(config: p1conf, scene: scene, depth: 0.0)
        scene.rootNode.addChildNode(self.player1!)
        let p1Stats = self.player1?.getStats()
        p1Stats?.position = CGPoint(x: self.spriteScene.size.width - 80, y: 200)
        self.spriteScene.addChild(p1Stats!)
        
        self.player2 = SCNPlayer(config: p2conf, scene: scene, depth: -8.0)    //8 meters deep
        self.player2?.eulerAngles = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
        scene.rootNode.addChildNode(self.player2!)
        let p2Stats = self.player2?.getStats()
        p2Stats?.position = CGPoint(x: 40, y: self.spriteScene.size.height - 80)
        self.spriteScene.addChild(p2Stats!)
        
        
        
        //Configure buttons
        self.configureButtons(turnPlayer == self.playerId)

    }
    
    /* @param - enable: Bool
     * true : make all buttons visible, but disable invalid buttons
     * false: hide all buttons
     */
    func configureButtons(_ enable: Bool){
        if enable {
            self.playButton.isHidden   = false
            self.drawButton.isHidden   = false
            self.attackButton.isHidden = false
            self.nextButton.isHidden   = false
            if self.player1!.getHand().isEmpty() {
                self.playButton.isEnabled = false
            } else {
                self.playButton.isEnabled = true
            }
            if self.player1!.getField().hasCreatures() {
                self.attackButton.isEnabled = true
            } else {
                self.attackButton.isEnabled = false
            }
        } else {
            self.playButton.isHidden   = true
            self.drawButton.isHidden   = true
            self.attackButton.isHidden = true
            self.nextButton.isHidden   = true
        }
    }
    
    func restartSession() {
        self.sceneView.overlaySKScene = nil
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.isWorldSetUp = false
    }
    
    @IBAction func connectAction(_ sender: Any) {

        if isWorldSetUp {
            debugprint("Leaving game")
            self.socket.emit("leaveGame",[])
            restartSession()
            connectButton.setTitle("Join", for: .normal)
        } else {
            debugprint("Attempting to join game")
            self.socket.emit("joinGame",[])
        }
    }
    
    
    @IBAction func toggleTray(_ sender: Any) {
        trayLauncher.toggleTray()
    }
    
    @IBAction func playAction(_ sender: Any) {
        debugprint("Playing a card")
        self.socket.emit("actionSelect", ["action":"play", "handCardSlot": 0])
    }
    
    @IBAction func drawAction(_ sender: Any) {
        debugprint("Drawing a card")
        /*if turn {
            self.player1!.getHand().draw(Int(arc4random_uniform(3)))
        } else {
            self.player2!.getHand().draw(Int(arc4random_uniform(3)))
        }
        turn = !turn;*/

        self.socket.emit("actionSelect", ["action":"draw"])
    }
    
    @IBAction func AttackAction(_ sender: Any) {
        
        if self.player2!.getField().hasCreatures() {
            let params = [
                "action" : "attack",
                "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot,
                "defenderSlot" : self.player2!.getField().getLeftMostCreature()!.slot
            ] as [String : Any]
            debugprint(params.description)
            self.socket.emit("actionSelect", params)
        } else {
            let params = [
                "action" : "directAttack",
                "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot
            ] as [String : Any]
            debugprint(params.description)
            self.socket.emit("actionSelect", params)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        NSLog("Requesting phase change")
        self.socket.emit("actionSelect", ["action":"nextPhase"])
    }
    
    
    /*
    func getHeadlines() {
        
        let jsonURLString:String = "http://\(self.host):3000/headlines/?token=ABC438s";
        guard let url = URL(string: jsonURLString) else
        {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            
            do {
                let newsAPIStruct = try
                    JSONDecoder().decode(NewsAPIStruct.self, from: data)
                
                for item in newsAPIStruct.headlines {
                    NSLog(item.headline);
                };
                /*
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                */
            } catch let jsonErr {
                print ("error: ", jsonErr)
            }
        }.resume();
    };*/
    
    // MARK: Socket Events
    
    private func setSocketEvents() {
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
        self.socket.on(clientEvent: .disconnect, callback: {data, ack in
            print("socket disconnected");
        });
        
        self.socket.on(clientEvent: .reconnect, callback: {data, ack in
            print("socket reconnected");
            self.debugprint("Attempting to reconnect to game")
            self.restartSession()
            self.socket.emit("joinGame",[])
        });
        
        self.socket.on(clientEvent: .error, callback: {data, ack in
            print("socket error");
        });
        /*
        self.socket.on("headlines_updated") {data, ack in
            self.getHeadlines();
        };*/

        self.socket.on("joinedGame") {data, ack in
            self.debugprint(data.description);
            let dataJSON = data[0] as! [String : Any]
            
            //print error and exit if any
            if let status = dataJSON["status"] as? String {
                if status == "error" {
                    self.debugprint(dataJSON["value"].debugDescription)
                    return
                }
            }
            
            self.debugprint("Joined game")
            
            if let config = dataJSON["value"] as? [String : Any] {
                self.setUpWorld(config: config)
                self.isWorldSetUp = true
                self.connectButton.setTitle("Leave", for: .normal)
            }
        }
        
        self.socket.on("actionResponse") {data, ack in
            self.debugprint(data.description);
            let dataJSON = data[0] as! [String : Any]
            
            //print error and exit if any
            if let status = dataJSON["status"] as? String {
                if status == "error" {
                    self.debugprint(dataJSON["value"].debugDescription)
                    return
                }
            }
            
            if let val = dataJSON["value"] as? [String : Any] {
                let playerId = val["player"] as! String
                let event = val["event"] as! String
                let result = val["result"] as! [Int]
                self.debugprint("Handling response [\(playerId),\(event),\(result.description)]")
                self.spriteScene.announcement = "\(playerId) \(event)"
                switch event {
                    case "draw" : self.drawHandler(playerId, result)
                    case "play" : self.playHandler(playerId, result)
                    case "attack" : self.attackHandler(playerId, result)
                    case "directAttack" : self.directAttackHandler(playerId, result)
                    case "endTurn" :
                        self.configureButtons(!(playerId == self.playerId))
                    default :
                        self.debugprint("Received \(event) event")
                }
            }
        }
        
    }
    
    // MARK: Socket Game-Specific Events
    
    func drawHandler(_ playerId:String, _ result:[Int]) {
        let cardId = result[0]
        if playerId == self.playerId {
            self.player1?.draw(cardId)
            self.configureButtons(true)
        } else {
            self.player2?.draw(cardId)
        }
    }
    
    func playHandler(_ playerId:String, _ result:[Int]) {
        let handSlot = result[0]
        let opCode = result[1]
        
        //Remove card from hand
        if playerId == self.playerId {
            self.player1?.playCard(handSlot: handSlot)
        } else {
            self.player2?.playCard(handSlot: handSlot)
        }
        
        //Resolve effect
        if opCode == 0 {    //summon
            let fieldSlot = result[2]
            let cardId = result[3]
            if playerId == self.playerId {
                self.player1?.summonCreature(cardId: cardId,fieldSlot: fieldSlot)
            } else {
                self.player2?.summonCreature(cardId: cardId,fieldSlot: fieldSlot)
            }
        } else if opCode == 1 {//gain life
            let affectedPlayer     = result[2]
            let amountOfLifeGained = result[3]
            if (playerId == self.playerId && affectedPlayer == 0) ||
                (playerId != self.playerId && affectedPlayer == 1) {
                print("This player gained one life")
                self.player1?.gainLife(amount: amountOfLifeGained)
            } else {
                print("Other player gained one life")
                self.player2?.gainLife(amount: amountOfLifeGained)
            }
        }
        self.configureButtons(playerId == self.playerId)
    }
    
    func attackHandler(_ playerId:String, _ result:[Int]) {
        let attackerSlot = result[0]
        let defenderSlot = result[1]
        let destroyed    = result[2]
        var attacker: SCNCreature
        var target: SCNCreature
        if playerId == self.playerId {
            attacker = self.player1!.getField().getCreature(slot: attackerSlot)!
            target = self.player2!.getField().getCreature(slot: defenderSlot)!
        } else {
            attacker = self.player2!.getField().getCreature(slot: attackerSlot)!
            target = self.player1!.getField().getCreature(slot: defenderSlot)!
        }
        attacker.attack(target: target, destroyed: destroyed)
        
        DispatchQueue.main.async {
            attacker.attack(target: target, destroyed: destroyed)
            self.attackButton.isEnabled = true
        }
    }
    
    func directAttackHandler(_ playerId:String, _ result:[Int]) {
        let attackerSlot = result[0]
        let damageDealt = result[1]
        if playerId == self.playerId {
            self.player1!.getField().getCreature(slot: attackerSlot)?.attackPlayer(target: self.player2!, damage: damageDealt)
        } else {
            self.player2!.getField().getCreature(slot: attackerSlot)?.attackPlayer(target: self.player1!, damage: damageDealt)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Set debug options
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

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
        NSLog("Session interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        NSLog("Session interruption ended")
    }
}
