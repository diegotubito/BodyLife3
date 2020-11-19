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
    
    var model : CustomerListModel! {get set}
    func loadCustomers(bySearch: String, offset: Int)
    func loadCustomers(offset: Int)
    func setImageForCustomer(_id: String, thumbnail: String)
  
}

protocol CustomerListViewContract {
    func showLoading()
    func hideLoading()
    func showSuccess()
    func showError()
    func reloadCell(row: Int)
    func reloadList()
    func scrollToSelectedCustomer()
}
