//
//  PaymentViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol PaymentViewModelContract {
    init(withView view : PaymentViewContract)
    var model : PaymentModel! {get}
    func setSelectedInfo(_ customer: BriefCustomer, _ register: SellRegisterModel)
    func saveNewPayment()
 

}

protocol PaymentViewContract {
    func displayInfo()
    func showSuccess()
    func showError()
    func showLoading()
    func hideLoading()
    func getAmountString() -> String
}
