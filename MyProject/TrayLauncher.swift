//
//  TrayLauncher.swift
//  MyProject
//
//  Created by Kevin Lee on 4/17/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import UIKit
import SpriteKit

class TrayLauncher: NSObject {
    
    let tray = SKView()
    let trayHeight:CGFloat = 200
    var handScene:SKHand    
    
    var launched: Bool = false
    
    override init() {
        let window = UIApplication.shared.keyWindow
        self.handScene = SKHand(size: CGSize(width: window!.frame.width, height: self.trayHeight))
        self.handScene.scaleMode = .aspectFill
        tray.presentScene(self.handScene)
        super.init()
    }
    
    func toggleTray(){
        if launched {
            dismissTray()
        } else {
            launchTray()
        }
        launched = !launched
    }
    
    func launchTray(){
        if let window = UIApplication.shared.keyWindow {
            tray.backgroundColor = UIColor.gray
            //tray.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTray)))
            window.addSubview(tray)
            
            //let trayHeight:CGFloat = 200
            let y = window.frame.height - trayHeight
            self.tray.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: trayHeight)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.tray.frame = CGRect(x: 0, y: y, width: self.tray.frame.width, height: self.tray.frame.height)
            }, completion: nil)
        }
    }
    
    func dismissTray(){
        UIView.animate(withDuration: 0.5, animations: {
            if let window = UIApplication.shared.keyWindow {
                self.tray.frame = CGRect(x: 0, y: window.frame.height, width: self.tray.frame.width, height: self.tray.frame.height)
            }
        })
    }
}
