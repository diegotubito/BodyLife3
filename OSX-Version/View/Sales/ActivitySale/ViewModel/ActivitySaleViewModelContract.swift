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
    func selectActivityAutomatically()
    func selectDiscountAutomatically()
    func setSelectedActivity(_ value: ActivityModel.NewRegister?)
    func setSelectedPeriod(_ value: PeriodModel.Populated?)
    func getSelectedPeriod() -> PeriodModel.Populated?
    func getSelectedActivity() -> ActivityModel.NewRegister?
    func getSelectedDiscount() -> DiscountModel.Register?
    func getTotals() -> (amount: Double, amountDiscounted: Double)
    func validate() -> Bool
    func getPeriods() -> [PeriodModel.Populated]
    func getActivities() -> [ActivityModel.NewRegister]
    func getDiscounts() -> [DiscountModel.Register]
    func setFromDate()
    func setEndDate()
    func setFromDate(value: Date)
    
    func save(fromDate: Date, toDate: Date, price: Double, priceList: Double) 
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
    func showFromDate(value: Date)
    func showEndDate(value: Date)
}
