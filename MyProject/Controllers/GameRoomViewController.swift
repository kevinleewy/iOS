//
//  GameRoomController.swift
//  MyProject
//
//  Created by Kevin Lee on 4/20/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit
import SocketIO

class GameRoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    // MARK: Views
    @IBOutlet weak var playersView: GameRoomPlayersView!
    @IBOutlet weak var spectatorsView: GameRoomSpectatorsView!
    @IBOutlet weak var controlPanelView: GameRoomControlPanelView!
    
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: ViewController variables
    var playerId: String = "Player"
    var roomId: String = "Player"
    var host: String = "localhost"
    var asPlayer: Bool = true
    var socketInitialized = false
    var manager: SocketManager?
    var socket: SocketIOClient!
    private var players: [String] = [String]()
    private var spectators: [String] = [String]()
    private var minPlayers:Int = 2
    private var maxPlayers:Int = 2
    private var minSpectators:Int = 0
    private var maxSpectators:Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTableViews()
        if socketInitialized {
            self.socket.emit("retrieveGameRoom")
        } else {
            initSocket()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpTableViews() {
        self.playersView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.playersView.dataSource = self
        self.playersView.delegate = self
        
        self.spectatorsView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.spectatorsView.dataSource = self
        self.spectatorsView.delegate = self
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.playersView {
            return "Players"
        }
        return "Spectators"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.playersView {
            return self.players.count
        }
        return self.spectators.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if tableView == self.playersView {
            cell.textLabel?.text = self.players[indexPath.row]
        } else {
            cell.textLabel?.text = self.spectators[indexPath.row]
        }
        return cell
    }
    
    // MARK: SocketIO
    
    func initSocket(){
        self.manager = SocketManager(socketURL: URL(string: "http://\(self.host):8080")!,config: [.log(false),.connectParams(["token": playerId])])
        self.socket = manager?.defaultSocket
        self.setSocketEvents()
        self.socket.connect()
    }
    
    func setSocketEvents() {
        
        self.socket.removeAllHandlers()
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.socketInitialized = true
            self.socket.emit("retrieveGameRoom")
        }
        
        self.socket.on(clientEvent: .disconnect, callback: {data, ack in
            print("socket disconnected")
        })
        
        self.socket.on(clientEvent: .reconnect, callback: {data, ack in
            print("socket reconnected")
            self.socket.emit("retrieveGameRoom")
        })
        
        self.socket.on(clientEvent: .error, callback: {data, ack in
            print("socket error")
        })
        
        self.socket.on("appError") {data, ack in
            let err = data[0] as! [Any]
            if let errorCode = err[0] as? Int,
                let errorMsg = err[1] as? String {
                displayError(message: errorMsg)
                print("Error \(errorCode.description): \(errorMsg)")
            }
        }
        
        self.socket.on("gameRoomRetrieved") {data, ack in
            
            if let dataJSON = data[0] as? [String : Any],
                let status = dataJSON["status"] as? Int {
                switch(status){
                    case 0:
                        print("Game has not started")
                        self.players = dataJSON["players"] as! [String]
                        self.spectators = dataJSON["spectators"] as! [String]
                        self.minPlayers = dataJSON["minPlayers"] as! Int
                        self.maxPlayers = dataJSON["maxPlayers"] as! Int
                        self.minSpectators = dataJSON["minSpectators"] as! Int
                        self.maxSpectators = dataJSON["maxSpectators"] as! Int
                        self.updateGameRoomDisplay()
                    case 1:
                        print("Game is active")
                        self.performSegue(withIdentifier: "ToGame", sender: nil)
                    case 2:
                        print("Game has ended")
                    default:
                        print("Unknown room status")
                }
            }
        }
        
        self.socket.on("playerJoined") {data, ack in
            if let newPlayer = data[0] as? String {
                self.players.append(newPlayer)
                self.updateGameRoomDisplay()
            }
        }
        
        self.socket.on("playerLeft") {data, ack in
            if let removedPlayer = data[0] as? String {
                self.players = self.players.filter({
                    $0 != removedPlayer
                })
                self.updateGameRoomDisplay()
            }
        }
        
        self.socket.on("spectatorAdded") {data, ack in
            if let newSpectator = data[0] as? String {
                self.spectators.append(newSpectator)
                self.updateGameRoomDisplay()
            }
        }
        
        self.socket.on("spectatorLeft") {data, ack in
            if let removedSpectator = data[0] as? String {
                self.spectators = self.spectators.filter({
                    $0 != removedSpectator
                })
                self.updateGameRoomDisplay()
            }
        }
        
        self.socket.on("gameStarted") {data, ack in
            self.performSegue(withIdentifier: "ToGame", sender: nil)
        }
    }
    
    func meetRequirementsToStartGame() -> Bool {
        return self.players[0] == self.playerId
            && self.minPlayers <= self.players.count && self.players.count <= self.maxPlayers
            && self.minSpectators <= self.spectators.count && self.spectators.count <= self.maxSpectators
    }
    
    func updateGameRoomDisplay(){
        //self.playersView.update(self.players)
        //self.spectatorsView.update(self.spectators)
        DispatchQueue.main.async(execute: {
            self.playersView.reloadData()
            self.spectatorsView.reloadData()
            self.startButton.isEnabled = self.meetRequirementsToStartGame()
        })
    }
    
    // MARK: Action Handlers
    
    
    @IBAction func startButtonAction(_ sender: Any) {
        self.socket.emit("startGame")
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        self.socket.emit("retrieveGameRoom")
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExitGameRoom" {
            let destinationVC = segue.destination as! MenuViewController
            destinationVC.playerId = self.playerId
            destinationVC.host = self.host
            destinationVC.loggedIn = true
            destinationVC.roomExists = true
        }
        
        if segue.identifier == "ToGame" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.playerId = self.playerId
            destinationVC.host = self.host
            destinationVC.manager = self.manager
            destinationVC.socket = self.socket
        }
    }
    
}
