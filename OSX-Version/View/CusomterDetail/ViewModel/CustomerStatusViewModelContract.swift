//
//  CustomerStatusViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol CustomerStatusViewModelContract {
    init(withView view: CustomerStatusViewContract, receivedCustomer: CustomerModel)
    var model : CustomerStatusModel! {get}
    func loadData()
}

protocol CustomerStatusViewContract {
    func reloadList()
    func showLoading()
    func hideLoading()
    func showData(value: CustomerStatusModel?)
}
