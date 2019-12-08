//
//  SellActivityModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

struct SellActivityModel {
    var filteredPeriods = [ActivityModel]()
    var activity = [ActivityModel]()
    var type = [ServiceTypeModel]()
    var discounts = [DiscountModel]()
    var selectedActivityType : ServiceTypeModel?
    var selectedActivity : ActivityModel?
    var selectedDiscount : DiscountModel?
    
    var selectedStatus : CustomerStatus?
    var selectedCustomer : CustomerModel!
}
