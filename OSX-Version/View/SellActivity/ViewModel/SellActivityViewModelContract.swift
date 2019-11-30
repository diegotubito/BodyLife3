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
    var model : SellActivityModel! {get}
    func loadMembership()
    func getActivities() -> [ActivityModel]
    func getFilteredPeriods() -> [PeriodModel]
    func setSelectedActivity(row: Int)
    func setSelectedPeriod(row: Int)
    func setSelectedDiscount(row: Int)
    func validate() -> Bool
    func getDiscountTitles() -> [String]
    func save()
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?)
    func autoSelectActivity()
    func estimateToDate()
}

protocol SellActivityViewContract {
    func reloadView()
    func showMembershipError()
    func reloadPeriod()
    func showLoading()
    func hideLoading()
    func enableSaveButton()
    func disableSaveButton()
    func getFromDate() -> Date
    func getToDate() -> Date
    func getAmount() -> String
    func selectActivityManually(position: Int)
    func setToDate(date: Date)
    func disableDates()
    func enableDates()
}
