//
//  ActivitySaleModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ActivitySaleModel {
    var selectedStatus : CustomerStatus?
    var selectedCustomer : CustomerModel.Customer!
    
    var fromDate = Date()
    var endDate = Date()
    
    var activities = [ActivityModel.NewRegister]()
    var periods = [PeriodModel.AUX_Period]()
    var discounts = [DiscountModel.NewRegister]()
    var selectedPeriod : PeriodModel.AUX_Period?
    var selectedActivity : ActivityModel.NewRegister?
    var selectedDiscount : DiscountModel.NewRegister?
}
