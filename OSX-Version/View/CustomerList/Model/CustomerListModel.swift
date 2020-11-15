//
//  CustomerListModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct CustomerListModel {
    var selectedCustomer : CustomerModel.Customer?
    var customersbyPages = [CustomerModel.Customer]()
    var customersbySearch = [CustomerModel.Customer]()
    var bySearch = false
    var imagesBySearch = [Images]()
    var imagesByPages = [Images]()
    
    struct Images {
        var image : NSImage?
        var _id : String
    }
}
