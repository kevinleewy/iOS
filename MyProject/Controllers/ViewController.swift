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
    var players = [SCNPlayer]()
    
    var manager: SocketManager?
    var socket: SocketIOClient!
    var host: String = ""
    
    var DEBUG = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //self.sceneView.showsStatistics = true
        
        // Set up spotlight attached to camera
        attachSpotLight()
        
        // Establish connection with server
        //connectToServer()
        
        // Pick a player
        //self.selectPlayer()
        
        // Set Up Socket Events
        self.setSocketEvents()
        
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
    
    func selectPlayer(){
        DispatchQueue.main.async {

            let alert = UIAlertController(title: "Player", message: "Select one", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Player 1", style: .default, handler: { [weak alert] (_) in
                self.playerId = self.playerId
            }))
            
            alert.addAction(UIAlertAction(title: "Player 2", style: .default, handler: { [weak alert] (_) in
                self.playerId = "Player2"
            }))
            
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
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
        let playersConfig = config["players"] as! [Any]
        let temp = playersConfig[0] as! [String: Any]
        
        var p1conf : [String : Any]
        var p2conf : [String : Any]
        if temp["id"] as? String == self.playerId {
            p1conf = playersConfig[0] as! [String: Any]
            p2conf = playersConfig[1] as! [String: Any]
        } else {
            p1conf = playersConfig[1] as! [String: Any]
            p2conf = playersConfig[0] as! [String: Any]
        }
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
        self.socket.emit("actionSelect", ["action":"draw"])
    }
    
    @IBAction func AttackAction(_ sender: Any) {
        
        if self.player2!.getField().hasCreatures() {
            let params = [
                "action" : "attack",
                "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot,
                "targetPlayerId" : self.player2!.getId(),
                "defenderSlot" : self.player2!.getField().getLeftMostCreature()!.slot
            ] as [String : Any]
            debugprint(params.description)
            self.socket.emit("actionSelect", params)
        } else {
            let params = [
                "action" : "directAttack",
                "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot,
                "targetPlayerId" : self.player2!.getId(),
            ] as [String : Any]
            debugprint(params.description)
            self.socket.emit("actionSelect", params)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        NSLog("Requesting phase change")
        self.socket.emit("actionSelect", ["action":"nextPhase"])
    }

    
    // MARK: Socket Events
    
    private func setSocketEvents() {
        
        self.socket.removeAllHandlers()
        
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

        self.socket.on("appError") {data, ack in
            let err = data[0] as! [Any]
            let errorCode = err[0] as! Int
            let errorMsg = err[1] as! String
            displayError(message: errorMsg)
            print("Error \(errorCode.description): \(errorMsg)")
        }
        
        self.socket.on("joinedGame") {data, ack in
            self.debugprint(data.description);
            self.debugprint("Joined game")
            
            if let config = data[0] as? [String : Any] {
                self.setUpWorld(config: config)
                self.isWorldSetUp = true
                self.connectButton.setTitle("Leave", for: .normal)
            }
        }
        
        self.socket.on("actionResponse") {data, ack in
            self.debugprint(data.description);
            let dataJSON = data[0] as! [[String:Any]]
            for eventObj in dataJSON {
                let playerId = eventObj["playerId"] as! String
                let event = eventObj["event"] as! String
                self.spriteScene.announcement = "\(playerId) \(event)"
                switch event {
                case "draw"   : self.drawHandler(playerId, eventObj["newCard"] as! Int)
                case "play"   : self.playHandler(playerId, eventObj["cardSlot"] as! Int)
                case "summon" : self.summonHandler(
                        playerId,
                        eventObj["fieldSlot"] as! Int,
                        eventObj["cardId"] as! Int
                    )
                case "heal" : self.healHandler(
                        playerId,
                        eventObj["amount"] as! Int
                    )
                case "attack" : self.attackHandler(
                        playerId,
                        eventObj["attackerSlot"] as! Int,
                        eventObj["targetPlayerId"] as! String,
                        eventObj["defenderSlot"] as! Int,
                        eventObj["targetDestroyed"] as! Bool
                    )
                case "directAttack" : self.directAttackHandler(
                        playerId,
                        eventObj["attackerSlot"] as! Int,
                        eventObj["targetPlayerId"] as! String,
                        eventObj["damageDealt"] as! Int
                    )
                case "endTurn" :
                    self.configureButtons(!(playerId == self.playerId))
                default :
                    self.debugprint("Received \(event) event")
                }
            }
        }
        
    }
    
    // MARK: Socket Game-Specific Events
    
    func drawHandler(_ playerId:String, _ cardId:Int) {
        if playerId == self.playerId {
            self.player1?.draw(cardId)
            self.configureButtons(true)
        } else {
            self.player2?.draw(cardId)
        }
    }
    
    func playHandler(_ playerId:String, _ handSlot:Int) {
        
        //Remove card from hand
        if playerId == self.playerId {
            self.player1?.playCard(handSlot: handSlot)
        } else {
            self.player2?.playCard(handSlot: handSlot)
        }
        self.configureButtons(playerId == self.playerId)
    }
    
    func summonHandler(_ playerId:String, _ fieldSlot:Int, _ cardId:Int) {
        
        if playerId == self.playerId {
            self.player1?.summonCreature(cardId: cardId,fieldSlot: fieldSlot)
        } else {
            self.player2?.summonCreature(cardId: cardId,fieldSlot: fieldSlot)
        }
        self.configureButtons(playerId == self.playerId)
    }
    
    func healHandler(_ playerId:String, _ amount:Int) {

        if (playerId == self.playerId) {
            self.player1?.gainLife(amount: amount)
        } else {
            self.player2?.gainLife(amount: amount)
        }
    }
    
    func attackHandler(_ playerId:String, _ attackerSlot:Int, _ targetPlayerId:String, _ defenderSlot:Int, _ destroyed:Bool) {

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
    }
    
    func directAttackHandler(_ playerId:String, _ attackerSlot:Int, _ targetPlayerId:String, _ damageDealt:Int) {

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
