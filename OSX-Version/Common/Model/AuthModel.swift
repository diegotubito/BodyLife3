//
//  AuthModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 09/11/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ModelRefreshToken: Decodable {
    public var token : String
    public var username : String?
    public var exp : Double?
}
