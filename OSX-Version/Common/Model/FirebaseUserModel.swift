//
//  UserSession.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//


struct FirebaseUserModel: Decodable, Encodable {
    var token : String?
    var username : String?
    var exp : Double?
    var uid : String!
    var displayName : String?
    var email : String?
    var emailVerified : Bool?
    var phoneNumber : String?
    var photoURL : String?
    var lastLoginAt : String?
    var createdAt : String?
   
}
