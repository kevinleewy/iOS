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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var isWorldSetUp = false
    var turn = true;
    
    var player1: SCNPlayer?
    var player2: SCNPlayer?
    
    var manager: SocketManager?
    var socket: SocketIOClient!
    var host: String = ""
    
    var DEBUG = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true

        // Establish connection with server
        connectToServer()
        
    }
    
    func debugprint(_ s:String){
        print(s)
    }
    
    func connectToServer() {
        
        DispatchQueue.main.async {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Connecting to Server", message: "Input IP of server", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                //textField.text = "192.168.1.110"
                textField.text = "192.168.17.221"
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.host = (textField?.text)!
                self.initSocket()   //initialize sockets
            }))
            
            // 4. Present the alert.
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func initSocket(){
        self.manager = SocketManager(socketURL: URL(string: "http://\(self.host):8080")!,config: [.log(false),.connectParams(["token": "Player1"])])
        self.socket = manager?.defaultSocket
        self.setSocketEvents()
        self.socket.connect()
    }
    
    func setUpWorld(config: [String: Any]){
        
        debugprint("Setting up world")
        debugprint(config.description)
        let p1conf = config["player1"] as! [String: Any]
        let p2conf = config["player2"] as! [String: Any]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.player1 = SCNPlayer(config: p1conf, scene: scene, depth: 0.0)
        scene.rootNode.addChildNode(self.player1!)
        
        self.player2 = SCNPlayer(config: p2conf, scene: scene, depth: -8.0)    //8 meters deep
        self.player2?.eulerAngles = SCNVector3(0.degreesToRadians, 180.degreesToRadians, 0.degreesToRadians)
        scene.rootNode.addChildNode(self.player2!)
        /*
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
         */
    }
    
    func restartSession() {
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
    
    @IBAction func playAction(_ sender: Any) {
        NSLog("Playing a card")
        self.socket.emit("actionSelect", ["action":"play", "handCardSlot": 0])
    }
    
    @IBAction func drawAction(_ sender: Any) {
        NSLog("Drawing a card")
        /*if turn {
            self.player1!.getHand().draw(Int(arc4random_uniform(3)))
        } else {
            self.player2!.getHand().draw(Int(arc4random_uniform(3)))
        }
        turn = !turn;*/

        self.socket.emit("actionSelect", ["action":"draw"])
    }
    
    @IBAction func AttackAction(_ sender: Any) {
        //NSLog((self.sceneView.session.currentFrame?.camera.transform.columns.3.debugDescription)!)
        if turn {
            if self.player2!.getField().hasCreatures() {
                //self.player1!.getField().getLeftMostCreature()?.attack(target: self.player2!.getField().getLeftMostCreature()!)
                let params = [
                    "action" : "attack",
                    "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot,
                    "defenderSlot" : self.player2!.getField().getLeftMostCreature()!.slot
                ] as [String : Any]
                debugprint(params.description)
                self.socket.emit("actionSelect", params)
            } else {
                //self.player1!.getField().getLeftMostCreature()?.attackPlayer(target: self.player2!, damage: 1)
                let params = [
                    "action" : "directAttack",
                    "attackerSlot" : self.player1!.getField().getLeftMostCreature()!.slot
                ] as [String : Any]
                debugprint(params.description)
                self.socket.emit("actionSelect", params)
            }
        } else {
            if self.player1!.getField().hasCreatures() {
                self.player2!.getField().getLeftMostCreature()?.attack(
                    target: self.player1!.getField().getLeftMostCreature()!,
                    destroyed: 1
                )
            } else {
                self.player2!.getField().getLeftMostCreature()?.attackPlayer(target: self.player1!, damage: 1)
            }
        }
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
                switch event {
                    case "draw" :
                        let cardId = result[0]
                        if playerId == "Player1" {
                            self.player1?.getHand().draw(cardId)
                        } else {
                            self.player2?.getHand().draw(cardId)
                        }
                    case "play" :
                        let cardId = result[0]
                        let handSlot = result[1]
                        let fieldSlot = result[2]
                        if playerId == "Player1" {
                            self.player1?.playCard(cardId: cardId, handSlot: handSlot, fieldSlot: fieldSlot)
                        } else {
                            self.player2?.playCard(cardId: cardId, handSlot: handSlot, fieldSlot: fieldSlot)
                        }
                    case "attack" :
                        let attackerSlot = result[0]
                        let defenderSlot = result[1]
                        let destroyed    = result[2]
                        
                        if playerId == "Player1" {
                            self.player1!.getField().getCreature(slot: attackerSlot)?.attack(
                                target: self.player2!.getField().getCreature(slot: defenderSlot)!,
                                destroyed: destroyed
                            )
                        } else {
                            self.player2!.getField().getCreature(slot: attackerSlot)?.attack(
                                target: self.player1!.getField().getCreature(slot: defenderSlot)!,
                                destroyed: destroyed
                            )
                        }
                    case "directAttack" :
                            let attackerSlot = result[0]
                            let damageDealt = result[1]
                            if playerId == "Player1" {
                                self.player1!.getField().getCreature(slot: attackerSlot)?.attackPlayer(target: self.player2!, damage: damageDealt)
                            } else {
                                self.player2!.getField().getCreature(slot: attackerSlot)?.attackPlayer(target: self.player1!, damage: damageDealt)
                            }
                    default :
                        self.debugprint("Received \(event) event")
                }
            }
        }
        
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
        NSLog("Session interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        NSLog("Session interruption ended")
    }
}
