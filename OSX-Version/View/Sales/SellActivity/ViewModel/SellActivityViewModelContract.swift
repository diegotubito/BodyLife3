//
//  SellActivityViewModelContract.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol SellActivityViewModelContract {
    init (withView view: SellActivityViewContract)
    var model : SellActivityModel! {get set}
    func loadMembership()
    func getTypes() -> [ServiceTypeModel]
    func getFilteredActivities() -> [ActivityModel]
    func setSelectedActivity(row: Int)
    func setSelectedType(row: Int)
    func setSelectedDiscount(row: Int)
    func validate() -> Bool
    func getDiscountTitles() -> [String]
    func save()
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?)
    func autoSelectType()
    func autoSelectActivity()
    func autoSelectDiscount()
    func estimateToDate()
    func calculateAmountToPay()
}

protocol SellActivityViewContract {
    func reloadTableViewType()
    func showMembershipError()
    func reloadTableViewActivity()
    func showLoading()
    func hideLoading()
    func enableSaveButton()
    func disableSaveButton()
    func getFromDate() -> Date
    func getToDate() -> Date
    func selectTypeManually(position: Int)
    func selectActivityManually(position: Int)
    func selectDiscountManually(position: Int)
    func setToDate(date: Date)
    func disableDates()
    func enableDates()
    func showError(_ message: String)
    func showSuccess()
    func showSuccessSaving()
    func displayAmountToPay(discount: Double, payment: Double)
}
