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
    var selectedCustomer : CustomerModel!
    
    var fromDate = Date()
    var endDate = Date()
    
    var activities = [ActivityModel]()
    var types = [ServiceTypeModel]()
    var discounts = [DiscountModel]()
    var selectedType : ServiceTypeModel?
    var selectedActivity : ActivityModel?
    var selectedDiscount : DiscountModel?
}
