//
//  GameRoomPlayersView.swift
//  MyProject
//
//  Created by Kevin Lee on 4/20/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit

class GameRoomPlayersView : UITableView {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        register(UITableViewCell.self, forCellReuseIdentifier: "cell");
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(_ players:[String]){
        for player in players {
            print(player)
        }
    }
    
    func addPlayer(){
        
    }
    
    func removePlayer(){
        
    }
}
