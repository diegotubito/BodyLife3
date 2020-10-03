//
//  ActivitySaleModelViewContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol ActivitySaleViewModelContract {
    init(withView view: ActivitySaleViewContract)
    func loadPeriods()
    func loadDiscounts()
    func setStatusInfo(_ statusInfo: CustomerStatusModel.StatusInfo?)
    
    func selectActivity(_ value: Int)
    func selectDiscount(_ value: Int)
    func setCustomerStatus(selectedCustomer: CustomerModel.Customer)
    func selectTypeAutomatically()
    func selectDiscountAutomatically()
    func setSelectedActivity(_ value: ActivityModel.NewRegister?)
    func setSelectedPeriod(_ value: PeriodModel.AUX_Period?)
    func getSelectedPeriod() -> PeriodModel.AUX_Period?
    func getSelectedActivity() -> ActivityModel.NewRegister?
    func getSelectedDiscount() -> DiscountModel.NewRegister?
    func getTotals() -> (amount: Double, amountDiscounted: Double)
    func validate() -> Bool
    func getPeriods() -> [PeriodModel.AUX_Period]
    func getActivities() -> [ActivityModel.NewRegister]
    func getDiscounts() -> [DiscountModel.NewRegister]
}

protocol ActivitySaleViewContract {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showActivities()
    func showSuccessSaving()
    func setPopupActivitydByTitle(_ value: String?)
    func setPopupDiscountByTitle(_ value: String?)
    func showPeriods()
    func showDiscounts()
}
