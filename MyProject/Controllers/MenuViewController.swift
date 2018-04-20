//
//  MenuViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 4/20/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit
import SocketIO

class MenuViewController: UIViewController {

    // MARK: View Elements
    @IBOutlet weak var menuButton1: UIButton!
    
    // MARK: ViewController variables
    var playerId: String = "Player"
    var host: String = "localhost"
    var roomExists: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promptForInfo()
        
    }

    func promptForInfo(){
        DispatchQueue.main.async {
            
            //Create the alert controller.
            let alert = UIAlertController(title: "Connecting to Server", message: "Input IP of server", preferredStyle: .alert)
            
            //Add Username text field
            alert.addTextField(configurationHandler: {(textField) in
                textField.placeholder = "Username"
            })
            
            //Add host IP text field
            alert.addTextField { (textField) in
                //textField.text = "192.168.1.110"  //home
                textField.text = "192.168.17.221"   //work
                //textField.text = "10.30.151.51" //stanford
            }
            
            //Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let userTextField = alert?.textFields![0] // Force unwrapping because we know it exists.
                let hostTextField = alert?.textFields![1] // Force unwrapping because we know it exists.
                self.playerId = (userTextField?.text)!
                self.host = (hostTextField?.text)!
                self.checkIfRoomExists()
            }))
            
            //Present the alert.
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkIfRoomExists() {
        
        let jsonURLString:String = "http://\(self.host):3000/room?token=\(self.playerId)";
        guard let url = URL(string: jsonURLString) else { return }
        print("1")
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            do {
                if let roomExists = try JSONSerialization.jsonObject(with: data, options: []) as? [Bool] {
                    DispatchQueue.main.async(execute: {
                        if roomExists[0] {
                            self.roomExists = true
                            self.menuButton1.setTitle("Join", for: UIControlState.normal)
                        } else {
                            self.roomExists = false
                            self.menuButton1.setTitle("Create", for: UIControlState.normal)
                        }
                    })
                }
            } catch let jsonErr {
                print ("error: ", jsonErr)
            }
        }.resume();
    }
    
    func createRoom(){
        
    }
    
    func joinRoom(){
        
    }
    
    // MARK: Button Action Handlers
    
    @IBAction func menuButton1Action(_ sender: Any) {
        if(roomExists){
            self.joinRoom()
        } else {
            self.createRoom()
        }
        return
    }
    
    @IBAction func menuButton2Action(_ sender: Any) {
        self.promptForInfo()
    }
}
