//
//  ActivitySaleViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivitySaleViewModel : ActivitySaleViewModelContract {
    var model: ActivitySaleModel!
    var _view : ActivitySaleViewContract!
    
    required init(withView view: ActivitySaleViewContract) {
        _view = view
        model = ActivitySaleModel()
    }
    
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?) {
        model.selectedStatus = selectedStatus
        model.selectedCustomer = selectedCustomer
    }
}
