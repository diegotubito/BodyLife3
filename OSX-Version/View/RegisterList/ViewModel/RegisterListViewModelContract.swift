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
    func loadData()
    func cancelRegister()
    func setSelectedCustomer(customer: CustomerModel.Customer)
    func getRegisters() -> RegisterListModel.Response?
    func setSelectedRegister(_ selectedRegister: RegisterListModel.ViewModel?)
    func getSelectedRegister() -> RegisterListModel.ViewModel?
    func setIsEnabled(row: Int)
   

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
