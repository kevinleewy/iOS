//
//  JSONReader.swift
//  MyProject
//
//  Created by Kevin Lee on 4/1/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import Foundation

class JSONData {
    
    private var jsonResult: Dictionary<String, AnyObject>?
    
    init(filename: String){
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                self.jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, AnyObject>
            } catch {
                // handle error
                NSLog("Unable to read \(filename)")
            }
        }
    }
    
    func getData() -> Dictionary<String, AnyObject>? {
        return jsonResult
    }
}
/*
 if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
 // do stuff
 }
 */
