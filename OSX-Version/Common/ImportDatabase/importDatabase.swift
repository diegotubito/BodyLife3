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
    
    static func codeUID(_ value: String) -> String {
        if value.isEmpty {
            return "000000000000000000000000"
        }
        let str = value
        let data = Data(str.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        var rounded = hexString.prefix(24)
        if rounded.count < 24 {
            let dif = (24 - rounded.count)
            for x in 0...(dif - 1) {
                rounded.append("0")
            }
        }
        return String(rounded)
    }
}


