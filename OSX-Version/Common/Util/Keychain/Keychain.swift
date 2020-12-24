//
//  keychainItem.swift
//  Production-Target
//
//  Created by David Diego Gomez on 24/12/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation
import KeychainSwift

enum KeychainKey: String{
    case bodyshapingAccessToken = "bodyshapingAccessToken"
    case userEmail = "userEmail"
}


class Keychain{
    
    private static let keychain = KeychainSwift()
    static let shared = Keychain()
    
    private init(){}
    
    //MARK: Set Keychain Object
    static func set(value: Any, forKey: KeychainKey){
        //String
        if let v = value as? String{ keychain.set(v, forKey: forKey.rawValue) }
        //Bool
        if let v = value as? Bool{ keychain.set(v, forKey: forKey.rawValue) }
        //Data
        if let v = value as? Data{ keychain.set(v, forKey: forKey.rawValue) }
    }
    
    //MARK: Get Keychain Object
    static func get(key: KeychainKey) -> String? { return keychain.get(key.rawValue) ?? nil }
    static func getBool(key: KeychainKey) -> Bool? { return keychain.getBool(key.rawValue) ?? nil }
    static func getData(key: KeychainKey) -> Data? { return keychain.getData(key.rawValue) ?? nil }
    
    //MARK: Clear
    static func clear() { keychain.clear(); }
    
}
