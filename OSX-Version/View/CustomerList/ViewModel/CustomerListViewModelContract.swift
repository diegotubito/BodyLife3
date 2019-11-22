//
//  CustomerListViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol CustomerListViewModelContract {
    init(withView view: CustomerListViewContract)
    
    var model : CustomerListModel! {get}
    
    func loadCustomers()
}

protocol CustomerListViewContract {
    func showLoading()
    func hideLoading()
    func showSuccess()
    func showError()
}
