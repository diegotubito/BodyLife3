//
//  CustomerStatusModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct CustomerStatusModel {
    var loadedStatus : CustomerStatus?
    var receivedCustomer : CustomerModel.Customer
    
    struct StatusInfo {
        var expiration : Date
        var balance : Double
        var customer : CustomerModel.Customer
        var lastActivityId : String?
        var lastPeriodId : String?
        var lastDiscountId : String?
    }
}
