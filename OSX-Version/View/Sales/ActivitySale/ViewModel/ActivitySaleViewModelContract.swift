//
//  ActivitySaleModelViewContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol ActivitySaleViewModelContract {
    init(withView view: ActivitySaleViewContract)
    
    var model : ActivitySaleModel! {get}
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?)
    
}

protocol ActivitySaleViewContract {
    
}
