//
//  importDatabase.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Cocoa

class JSONFile {
    
    static func loadBodyLife() -> [String : Any]? {
        if let path = Bundle.main.path(forResource: "bodyshaping", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String : Any]
                if let bodyLife = jsonResult!["BodyLife"] as? [String : Any] {
                    // do stuff
                    return bodyLife
                }
                return nil
            } catch {
                // handle error
                return nil
            }
        }
        return nil
        
    }
}

class ImportDatabase : JSONFile{
    
    static let instance = ImportDatabase()
    
}


