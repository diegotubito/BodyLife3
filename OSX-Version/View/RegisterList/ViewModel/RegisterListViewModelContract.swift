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
    func setSelectedCustomer(customer: BriefCustomer)
    func getRegisters() -> [SellRegisterModel]
    func setSelectedRegister(_ selectedRegister: SellRegisterModel?)
    func getSelectedRegister() -> SellRegisterModel?
    func setIsEnabled(row: Int)

}

protocol RegisterListViewContract {
    func displayData()
    func showError(value: String)
    func showLoading()
    func hideLoading()
    func setSelectedCustomer(customer: BriefCustomer)
    func updateButtonState()
    func cancelSuccess()
    func cancelError()
}
