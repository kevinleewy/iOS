//
//  GameRoomController.swift
//  MyProject
//
//  Created by Kevin Lee on 4/20/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit
import SocketIO

class GameRoomViewController: UIViewController {

    
    // MARK: Views
    @IBOutlet weak var playersView: GameRoomPlayersView!
    @IBOutlet weak var spectatorsView: GameRoomSpectatorsView!
    @IBOutlet weak var controlPanelView: GameRoomControlPanelView!
    
    
    // MARK: ViewController variables
    var playerId: String = "Player"
    var roomId: String = "Player"
    var host: String = "localhost"
    var asPlayer: Bool = true
    var manager: SocketManager?
    var socket: SocketIOClient!
    var players: [String]?
    var spectators: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSocket()
    }
    
    func initSocket(){
        self.manager = SocketManager(socketURL: URL(string: "http://\(self.host):8080")!,config: [.log(false),.connectParams(["token": playerId])])
        self.socket = manager?.defaultSocket
        self.setSocketEvents()
        self.socket.connect()
    }
    
    func setSocketEvents() {
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
            self.socket.emit("retrieveGameRoom")
        };
        
        self.socket.on(clientEvent: .disconnect, callback: {data, ack in
            print("socket disconnected");
        });
        
        self.socket.on(clientEvent: .reconnect, callback: {data, ack in
            print("socket reconnected");
            self.socket.emit("retrieveGameRoom")
        });
        
        self.socket.on(clientEvent: .error, callback: {data, ack in
            print("socket error");
        });
        
        self.socket.on("appError") {data, ack in
            let err = data[0] as! [Any]
            let errorCode = err[0] as? Int
            let errorMsg = err[1] as? String
            print("Error \(errorCode?.description ?? "??"): \(errorMsg ?? "Unknown")")
        }
        
        self.socket.on("gameRoomRetrieved") {data, ack in
            
            if let dataJSON = data[0] as? [String : Any],
                let status = dataJSON["status"] as? Int {
                switch(status){
                    case 0:
                        print("Game has not started")
                        self.players = dataJSON["players"] as? [String]
                        self.spectators = dataJSON["spectators"] as? [String]
                    case 1:
                        print("Game is active")
                    case 2:
                        print("Game has ended")
                    default:
                        print("Unknown room status")
                }
            }
        }
    }
    
}
