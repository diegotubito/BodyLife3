//
//  UserSession.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

struct FirebaseUserModel: Decodable {
    var token : String
    var username : String?
    var exp : Double?
    var uid : String!
    var displayName : String?
    var email : String?
    var email_verified : Bool?
    var phoneNumber : String?
    var photoURL : String?
    var lastLoginAt : String?
    var createdAt : String?
    var stsTokenManager = Token()
    
    struct Token : Decodable {
        var accessToken : String!
        var expirationTime : Double!
    }
}


struct TokenUserModel: Decodable {
    var token : String
    var username : String?
    var exp : Double?
}
