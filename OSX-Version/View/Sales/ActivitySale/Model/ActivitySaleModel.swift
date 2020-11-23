//
//  ActivitySaleModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ActivitySaleModel {
    var selectedCustomer : CustomerModel.Customer!
    var endDate = Date()
    var fromDate = Date()
    var statusInfo : CustomerStatusModel.StatusInfo?
    
    var activities = [ActivityModel.NewRegister]()
    var periods = [PeriodModel.Populated]()
    var discounts = [DiscountModel.Register]()
    var selectedPeriod : PeriodModel.Populated?
    var selectedActivity : ActivityModel.NewRegister?
    var selectedDiscount : DiscountModel.Register?
}
