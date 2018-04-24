//
//  MenuViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 4/20/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    // MARK: View Elements
    @IBOutlet weak var menuButton0: UIButton!
    @IBOutlet weak var menuButton1: UIButton!
    
    // MARK: ViewController variables
    var playerId: String = "Player"
    var host: String = "localhost"
    var roomExists: Bool = false
    var loggedIn: Bool = false
    var language: String = "EN"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if loggedIn {
            self.checkIfRoomExists()
        } else {
            promptForInfo()
        }
        
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
                textField.text = "192.168.1.110"  //home
                //textField.text = "192.168.17.221"   //work
                //textField.text = "10.30.134.101" //stanford
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
        
        let jsonURLString:String = "http://\(self.host):3000/room/\(self.playerId)";
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            guard let data = data else { return }
            do {
                if let roomExists = try JSONSerialization.jsonObject(with: data, options: []) as? [Bool] {
                    DispatchQueue.main.async(execute: {
                        if roomExists[0] {
                            self.roomExists = true
                            self.menuButton0.setTitle("Enter", for: UIControlState.normal)
                            self.menuButton1.setTitle("Leave", for: UIControlState.normal)
                        } else {
                            self.roomExists = false
                            self.menuButton0.setTitle("Create", for: UIControlState.normal)
                            self.menuButton1.setTitle("Join", for: UIControlState.normal)
                        }
                    })
                }
            } catch let jsonErr {
                print ("error: ", jsonErr)
            }
        }.resume();
    }
    
    func createRoom() {

        let jsonURLString:String = "http://\(self.host):3000/room/\(self.playerId)";
        guard let url = URL(string: jsonURLString) else { return }

        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //let postString = "token=\(self.playerId)"
        //request.httpBody = postString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error.debugDescription)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            }
            do {
                if let dataJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    let status = dataJSON["status"] as! String
                    if status == "error" {
                        if let errorMsg = dataJSON["message"] as? String {
                            displayError(message: errorMsg)
                        }
                    } else if status == "success" {
                        self.roomExists = true
                    } else {
                        print("Unknown status")
                    }
                }
            } catch let jsonErr {
                print ("error: ", jsonErr)
            }
        }.resume()
        
    }
    
    func joinRoom() {
        DispatchQueue.main.async {
            
            //Create the alert controller.
            let alert = UIAlertController(title: "Join A Game Room", message: "Input room ID", preferredStyle: .alert)
            
            //Add Username text field
            alert.addTextField(configurationHandler: {(textField) in
                textField.placeholder = "Room ID"
            })
            
            //Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let roomId = alert?.textFields![0].text {
                
                    let jsonURLString:String = "http://\(self.host):3000/room/\(self.playerId)?roomId=\(roomId)&lang=\(self.language)"
                    guard let url = URL(string: jsonURLString) else { return }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            // check for fundamental networking error
                            print("error=\(error.debugDescription)")
                            return
                        }
                        
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            // check for http errors
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(response.debugDescription)")
                        }
                        do {
                            if let dataJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                DispatchQueue.main.async(execute: {
                                    let status = dataJSON["status"] as! String
                                    if status == "error" {
                                        if let errorMsg = dataJSON["message"] as? String {
                                            displayError(message: errorMsg)
                                        }
                                    } else if status == "success" {
                                        self.roomExists = true
                                        self.performSegue(withIdentifier: "ToGameRoomAsPlayer", sender: nil)
                                    } else {
                                        print("Unknown status")
                                    }
                                })
                            }

                        } catch let jsonErr {
                            print ("error: ", jsonErr)
                        }
                    }.resume()
                }
            }))
            
            //Present the alert.
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func leaveRoom() {
        let jsonURLString:String = "http://\(self.host):3000/room/\(self.playerId)";
        guard let url = URL(string: jsonURLString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error.debugDescription)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response.debugDescription)")
            }
            do {
                if let dataJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    let status = dataJSON["status"] as! String
                    if status == "error" {
                        if let errorMsg = dataJSON["message"] as? String {
                            displayError(message: errorMsg)
                        }
                    } else if status == "success" {
                        self.checkIfRoomExists()
                    } else {
                        print("Unknown status")
                    }
                }
            } catch let jsonErr {
                print ("error: ", jsonErr)
            }
        }.resume()
    }
    
    // MARK: Button Action Handlers
    
    
    @IBAction func menuButton0Action(_ sender: Any) {
        if(!self.roomExists){
            self.createRoom()   //will also set self.roomExists to true if succeeds
        }
        while(!self.roomExists){
            //do nothing
            print("Waiting for room to be created")
            sleep(1)
        }
        performSegue(withIdentifier: "ToGameRoomAsPlayer", sender: nil)
    }
    
    @IBAction func menuButton1Action(_ sender: Any) {
        if(!self.roomExists){
            self.joinRoom()
        } else {
            self.leaveRoom()
        }
    }
    
    @IBAction func menuButton2Action(_ sender: Any) {
        self.promptForInfo()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        return self.roomExists
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGameRoomAsPlayer" {
            let destinationVC = segue.destination as! GameRoomViewController
            destinationVC.playerId = self.playerId
            destinationVC.roomId = self.playerId
            destinationVC.host = self.host
            destinationVC.asPlayer = true
        }
        if segue.identifier == "ToGameRoomAsSpectator" {
            let destinationVC = segue.destination as! GameRoomViewController
            destinationVC.playerId = self.playerId
            destinationVC.roomId = self.playerId
            destinationVC.host = self.host
            destinationVC.asPlayer = false
        }
    }
    
}
