//
//  CustomerListModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct CustomerListModel {
    var registros = [BriefCustomer]()
    var selectedCustomer : BriefCustomer?
    
    var response : Response?
    
    struct Response :Decodable {
        var response : String
        var customers : [CustomerModel.Request]
        var total_amount : Int
    }
}
