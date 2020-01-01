//
//  SellActivityViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class SellActivityViewModel: SellActivityViewModelContract {
   
    var model: SellActivityModel!
    var _view : SellActivityViewContract!
    var childIDNew : String?
    
    required init(withView view: SellActivityViewContract) {
        _view = view
        model = SellActivityModel()
    }
    
    func loadMembership() {
        let path = Paths.productService
        _view.showLoading()
        ServerManager.ReadJSON(path: path) { (json, error) in
            self._view.hideLoading()
            if error != nil {
                self._view.showMembershipError()
                return
            }
            guard let json = json else {
                self._view.showMembershipError()
                return
            }
            do {
                if let activityTypesJSON = json["type"] as? [String : Any] {
                    let activityTypeArray = ServerManager.jsonArray(json: activityTypesJSON)
                    let dataActivityType = try JSONSerialization.data(withJSONObject: activityTypeArray, options: [])
                    self.model.type = try JSONDecoder().decode([ServiceTypeModel].self, from: dataActivityType)
                }
                if let activityJSON = json["activity"] as? [String : Any] {
                    let activityArray = ServerManager.jsonArray(json: activityJSON)
                    let dataActivity = try JSONSerialization.data(withJSONObject: activityArray, options: [])
                    self.model.activity = try JSONDecoder().decode([ActivityModel].self, from: dataActivity)
                }
                if let discountJSON = json["discount"] as? [String : Any] {
                    let discountArray = ServerManager.jsonArray(json: discountJSON)
                    let dataDiscount = try JSONSerialization.data(withJSONObject: discountArray, options: [])
                    self.model.discounts = try JSONDecoder().decode([DiscountModel].self, from: dataDiscount)                    
                }
                self._view.showSuccess()
            } catch {
                self._view.showMembershipError()
            }
        }
    }
    
    func save() {
        let childIDCustomer = model.selectedCustomer.childID
        let childIDNew = ServerManager.createNewChildID()
        let statusJSON = prepareStatus(childID: childIDNew)
        let sellJSON = prepareSell(childID: childIDNew)
        let statusPath = "\(Paths.customerStatus):\(childIDCustomer)"
        let statusPathSell = "\(Paths.fullPersonalData):\(childIDCustomer):sells"
        let statusPathTransaction = "\(Paths.customerStatus):\(childIDCustomer)"
        let pathSell = Paths.sells
        var error : ServerError?
        let semasphore = DispatchSemaphore(value: 0)
        
        updateSellcountForActivity((model.selectedActivity?.childID)!)
        
        saveNewMembership(datos: sellJSON, path: statusPathSell) { (err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError("No se pudo guardar la venta en Status.")
            return
        }
        
        saveNewMembership(datos: sellJSON, path: pathSell) { (err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError("No se pudo guardar la venta.")
            return
        }
        
        saveNewMembership(datos: statusJSON, path: statusPath) { (err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            _view.showError("No se pudo actualizar el Status del socio.")
            return
        }
        
        let amountToPay = estimateAmount()
        saveNewTransaction(path: statusPathTransaction, value: -amountToPay)
        
        _view.showSuccessSaving()
    }
    
    private func updateSellcountForActivity(_ childIDActivity: String) {
        let pathArticleSellCount = "\(Paths.productService):activity:\(childIDActivity)"
        ServerManager.Transaction(path: pathArticleSellCount, key: "sellCount", value: 1, success: {
        }) { (err) in
            
        }
    }
    
    func saveNewMembership(datos: [String: Any], path: String, completion: @escaping (ServerError?) -> ()) {
        ServerManager.Update(path: path, json: datos) { (data, error) in
            completion(error)
        }
    }
    
    func saveNewTransaction(path: String, value: Double) {
        ServerManager.Transaction(path: path, key: "balance", value: value, success: {
            print("transaction made")
        }) { (error) in
        }
    }
    
    func prepareStatus(childID: String) -> [String : Any] {
        let childIDCustomer = model.selectedCustomer.childID
        let surname = model.selectedCustomer.surname
        let name = model.selectedCustomer.name
        let childIDLastType = (model.selectedType?.childID)!
        let childIDLastActivity = (model.selectedActivity?.childID)!
        let childIDLastDiscount = (model.selectedDiscount?.childID) ?? ""
        let status = ["surname" : surname,
                      "name": name,
                      "expiration": _view.getToDate().timeIntervalSince1970,
                      "childID": childIDCustomer,
                      "childIDLastType": childIDLastType,
                      "childIDLastActivity": childIDLastActivity,
                      "childIDLastDiscount":childIDLastDiscount] as [String : Any]
        return status
    }
    
    func prepareSell(childID: String) -> [String : Any] {
        let displayName = model.selectedActivity!.name + ", " + model.selectedType!.name
        let fromDate = _view.getFromDate()
        let toDate = _view.getToDate()
        let childIDLastType = model.selectedType?.childID
        let childIDLastActivity = model.selectedActivity?.childID
        let childIDLastDiscount = model.selectedDiscount?.childID
        let price = estimateAmount()
        let discount = model.selectedDiscount?.multiplier
        let childIDCustomer = model.selectedCustomer.childID
        let sell = [childID:["childID" : childID,
                             "childIDCustomer" : childIDCustomer,
                             "createdAt" : Date().timeIntervalSince1970,
                             "fromDate" : fromDate.timeIntervalSince1970,
                             "toDate" : toDate.timeIntervalSince1970,
                             "price" : price,
                             "isEnabled" : true,
                             "childIDLastType" : childIDLastType!,
                             "childIDLastActivity" : childIDLastActivity!,
                             "childIDLastDiscount" : childIDLastDiscount ?? "",
                             "discount" : discount ?? 1.0,
                             "displayName" : displayName]]
            as [String : Any]
        
        return sell
    }
    
    func getTypes() -> [ServiceTypeModel] {
        return model.type
    }
    
    func setSelectedType(row: Int) {
        if row == -1 {
            model.selectedType = nil
            model.filteredActivities = [ActivityModel]()
            _view.reloadTableViewActivity()
            _ = validate()
            return
        }
        model.selectedType = model.type[row]
        
        model.filteredActivities = model.activity.filter({$0.childIDType == model.selectedType!.childID})
        
        _view.reloadTableViewActivity()
        calculateAmountToPay()
        _ = validate()
    }
    
    func setSelectedActivity(row: Int) {
        if row == -1 {
            model.selectedActivity = nil
            _ = validate()
            return
        }
        model.selectedActivity = model.activity[row]
        estimateToDate()
        calculateAmountToPay()
        
        _ = validate()
        
    }
    
    func setSelectedDiscount(row: Int) {
        if row == 0 {
            model.selectedDiscount = nil
        } else {
            model.selectedDiscount = model.discounts[row - 1]
        }
    }
    
    func estimateAmount() -> Double {
        var amount : Double = 0
        
        if let period = model.selectedActivity, model.selectedType != nil {
            amount = period.price
        }
        if let discount = model.selectedDiscount {
            amount = amount * discount.multiplier
        }
        
        return amount
    }
    
    func estimateToDate() {
        
        if model.selectedActivity == nil {
            _view.setToDate(date: _view.getFromDate())
            return
        }
        let selectedPeriod = model.selectedActivity
        let days = selectedPeriod?.days
        let toDate = _view.getFromDate()
        _view.setToDate(date: Calendar.current.date(byAdding: .day, value: days!, to: toDate)!)
    }
    
    func validate() -> Bool {
        var result = true
        if model.selectedType == nil {
            result = false
        }
        if model.selectedActivity == nil {
            _view.disableDates()
            result = false
        }else {
            _view.enableDates()
        }
        
        if result {
            _view.enableSaveButton()
        } else {
            _view.disableSaveButton()
        }
        
        return result
    }
    
    func getFilteredActivities() -> [ActivityModel] {
        return model.filteredActivities
    }
    
    func getDiscountTitles() -> [String] {
        let titles = model.discounts.map({$0.name})
        return titles
    }
    
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?) {
        model.selectedStatus = selectedStatus
        model.selectedCustomer = selectedCustomer
    }
    
    func autoSelectType() {
        model.selectedType = nil
        for (x,i) in (model!.type).enumerated() {
            if i.childID == model.selectedStatus?.childIDLastType {
                _view.selectTypeManually(position: x)
                
            }
        }
    }
    
    func autoSelectActivity() {
        model.selectedActivity = nil
        for (x,i) in (model!.activity).enumerated() {
            if i.childID == model.selectedStatus?.childIDLastActivity {
                _view.selectActivityManually(position: x)
            }
        }
    }
    
    func autoSelectDiscount() {
        model.selectedDiscount = nil
        for (x,i) in (model!.discounts).enumerated() {
            if i.childID == model.selectedStatus?.childIDLastDiscount {
                _view.selectDiscountManually(position: x)
            }
        }
    }
    
    func calculateAmountToPay() {
        var multiplier : Double = 1
        if let val = model.selectedDiscount?.multiplier {
            multiplier = val
        }
        let price = model.selectedActivity == nil ? 0 : model.selectedActivity?.price
         
        let totalDiscount = price! - (multiplier * price!)
        let totalToPay = price! - totalDiscount
        _view.displayAmountToPay(discount: totalDiscount, payment: totalToPay)
    }
    
}
