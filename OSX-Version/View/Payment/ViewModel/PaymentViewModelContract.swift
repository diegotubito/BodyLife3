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
    var model : NewPaymentModel! {get}
    func setSelectedInfo(_ customer: CustomerModel.Customer, _ register: SellModel.NewRegister, payments: [PaymentModel.NewRegister])
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
