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
    
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?)
    func loadServices()
    func getActivities() -> [ActivityModel]
    func getTypes() -> [ServiceTypeModel]
    func getDiscounts() -> [DiscountModel]
    func selectTypeAutomatically()
    func selectDiscountAutomatically()
    func selectType(_ value: Int)
    func selectDiscount(_ value: Int)
    func setSelectedActivity(_ value: ActivityModel?)
    func getSelectedActivity() -> ActivityModel?
    func getProperFromDate() -> Date
    func getTotals() -> (price: Double, discount: Double)
    func validate() -> Bool
    func save()
}

protocol ActivitySaleViewContract {
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    func showSuccess()
    func showSuccessSaving()
    func setPopupTypeByTitle(_ value: String?)
    func setPopupDiscountByTitle(_ value: String?)
    func showActivities() 
    func adjustDates()
    func getToDate() -> Date
    func getFromDate() -> Date
}
