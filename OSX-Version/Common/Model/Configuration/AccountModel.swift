//
//  AccountModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 06/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

struct CashAccountModel: Codable {
    var id : String
    var description : String
    var amount : Double
    var isEnabled : Bool
    var timestamp : Double
    var userRole : String
    var isPermanent : Bool
    var needNotification: Bool
}
