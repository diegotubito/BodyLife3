//
//  CustomerStatusViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class CustomerStatusViewModel: CustomerStatusViewModelContract {
    var model: CustomerStatusModel!
    var _view : CustomerStatusViewContract!
    
    required init(withView view: CustomerStatusViewContract, receivedCustomer: CustomerModel.Customer?) {
        self._view = view
        self.model = CustomerStatusModel(receivedCustomer: receivedCustomer)
    }
    
}
