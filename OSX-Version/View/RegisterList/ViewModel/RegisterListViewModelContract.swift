//
//  RegisterListViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol RegisterListViewModelContract {
    init(withView view: RegisterListViewContract)
    func loadPayments()
    func cancelRegister()
    func realDeleteEveryRelatedSellAndPayment()
    func setSelectedCustomer(customer: CustomerModel.Customer?)
    
    func getSells() -> [SellModel.Register]
    func getPayments() -> [PaymentModel.Populated]
    func getPaymentsForSelectedRegister() -> [PaymentModel.Populated]
    
    func setSelectedRegister(_ selectedRegister: SellModel.Register?)
    func getSelectedRegister() -> SellModel.Register?
    func setIsEnabled(row: Int)
    func initValues()

}

protocol RegisterListViewContract {
    func displayData()
    func showError(value: String)
    func showLoading()
    func hideLoading()
    func setSelectedCustomer(customer: CustomerModel.Customer)
    func updateButtonState()
    func cancelSuccess()
    func cancelError()
    func notificateStatusInfo(data: CustomerStatusModel.StatusInfo?)
}
