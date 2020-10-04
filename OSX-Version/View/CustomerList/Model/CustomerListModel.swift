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
    var customersToDisplay = [CustomerModel.Customer]()
    var bySearch = false
    var response : Response!
    var imagesToDisplay = [Images]()
    var imagesBySearch = [Images]()
    var imagesByPages = [Images]()
    var countByPages : Int = 0
    var countBySearch : Int = 0
    
    struct Response :Decodable {
        var response : String
        var customers : [CustomerModel.Customer]
        var count : Int
    }
    
    struct Images {
        var image : NSImage?
        var _id : String
    }
}
