//
//  Util.swift
//  MyProject
//
//  Created by Kevin Lee on 4/2/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

enum Phase :Int {
    case notMyTurn,
    drawPhase,
    mainPhase
}

enum AttackingState :Int {
    case notAttacking,
    selectAttacker,
    selectTarget
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension SCNNode {
    func getSCNCreature(depth: Int) -> SCNCreature? {
        if depth < 0 {
            return nil
        }
        
        if let creature = self as? SCNCreature {
            return creature
        }
        
        return self.parent?.getSCNCreature(depth: depth - 1)
    }
}

/*
 * Clean way to get top view controller:
 *   e.g.: UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
 */
extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}

func displayError(message:String){
    DispatchQueue.main.async(execute: {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    })
}


//MARK: Delay func
//Usage: delay(1){delayed code}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
