//
//  RegisterListModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListModel {
    var response : Response?
    var selectedCustomer : CustomerModel.Customer!
    var selectedSellRegister : RegisterListModel.ViewModel?!
   
    
    struct Response : Decodable {
        var response : String
        var sells : [ViewModel]
        var count : Int
    }
  
    struct ViewModel : Decodable{
        var _id: String
        var isEnabled : Bool
        var fromDate : Double?
        var toDate : Double?
        var timestamp: Double
        var productCategory : String
        var price : Double
        var priceList : Double
        var customer : CustomerModel.Customer
        var activity: ActivityModel.NewRegister?
        var discount: DiscountModel.NewRegister?
        var period : PeriodModel.NewRegister?
        var article : ArticleModel.NewRegister?
  
        var balance : Double?
        var totalPayment : Double?
        
        var payments : [PaymentModel.ViewModel]?
    }
}
