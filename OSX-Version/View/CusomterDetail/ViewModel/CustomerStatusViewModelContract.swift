//
//  CustomerStatusViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol CustomerStatusViewModelContract {
    init(withView view: CustomerStatusViewContract, receivedCustomer: CustomerModel.Customer)
    var model : CustomerStatusModel! {get}
}

protocol CustomerStatusViewContract {
}
