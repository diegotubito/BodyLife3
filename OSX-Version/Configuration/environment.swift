//
//  environment.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/10/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

enum Server: String {
    case Develop = "http://127.0.0.1:2999"
    case Production = "https://bodyshaping-heroku.herokuapp.com"
}

class Config {
    static let shared = Config()
    
    static var baseUrl : Server!
    
    struct URL {
        struct Firebase {
            static let Login = baseUrl.rawValue + "/v1/firebase/auth/login"
            static let currentUser = baseUrl.rawValue + "v1/firebase/auth/currentUser"
        }
        
        struct Server {
            static let RefreshToken =  baseUrl.rawValue + "/v1/firebase/auth/refreshToken"
            static let ConnectMongodb = baseUrl.rawValue + "/v1/connect-mongodb"
            static let DisconnectMongodb = baseUrl.rawValue + "/v1/close-mongodb"
        }
    }
}
