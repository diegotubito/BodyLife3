//
//  SellActivityModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct SellActivityModel {
    var filteredPeriods = [PeriodModel]()
    var periods = [PeriodModel]()
    var activities = [ActivityModel]()
    var discounts = [DiscountModel]()
    var selectedActivity : ActivityModel?
    var selectedPeriod : PeriodModel?
    var selectedDiscount : DiscountModel?
    
    var selectedStatus : CustomerStatus?
    var selectedCustomer : CustomerModel!
}
