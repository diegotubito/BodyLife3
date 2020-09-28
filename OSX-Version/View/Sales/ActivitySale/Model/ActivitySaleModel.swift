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
    var selectedCustomer : BriefCustomer!
    
    var fromDate = Date()
    var endDate = Date()
    
    var activities = [ActivityModel.Register]()
    var types = [ServiceTypeModel]()
    var discounts = [DiscountModel.Register]()
    var selectedType : ServiceTypeModel?
    var selectedActivity : ActivityModel.Register?
    var selectedDiscount : DiscountModel.Register?
}
