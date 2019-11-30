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
    
    required init(withView view: SellActivityViewContract) {
        _view = view
        model = SellActivityModel()
    }
    
    func loadMembership() {
        let path = "configuration:membership"
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
                if let activitiesJSON = json["activity"] as? [String : Any] {
                    let activitiesArray = ServerManager.jsonArray(json: activitiesJSON)
                    let dataActivity = try JSONSerialization.data(withJSONObject: activitiesArray, options: [])
                    self.model.activities = try JSONDecoder().decode([ActivityModel].self, from: dataActivity)
                }
                if let periodJSON = json["period"] as? [String : Any] {
                    let periodArray = ServerManager.jsonArray(json: periodJSON)
                    let dataPeriod = try JSONSerialization.data(withJSONObject: periodArray, options: [])
                    self.model.periods = try JSONDecoder().decode([PeriodModel].self, from: dataPeriod)
                }
                if let discountJSON = json["discount"] as? [String : Any] {
                    let discountArray = ServerManager.jsonArray(json: discountJSON)
                    let dataDiscount = try JSONSerialization.data(withJSONObject: discountArray, options: [])
                    self.model.discounts = try JSONDecoder().decode([DiscountModel].self, from: dataDiscount)                    
                }
                self._view.reloadView()
                
            } catch {
                self._view.showMembershipError()
            }
        }
    }
    
    func save() {
        let childIDCustomer = model.selectedCustomer.childID
        let fechaDouble = Date().timeIntervalSince1970
        let fechaRounded = (fechaDouble * 1000)
        let childID = String(Int(fechaRounded))
        let surname = model.selectedCustomer.surname
        let name = model.selectedCustomer.name
        let childIDLastActivity = (model.selectedActivity?.childID)!
        let childIDLastPeriod = (model.selectedPeriod?.childID)!
        let childIDLastDiscount = (model.selectedDiscount?.childID) ?? ""
        
        let sell = prepareSell(childID: childID)
        
        let status = ["surname" : surname,
                      "name": name,
                      "balance": 0,
                      "expiration": Date().timeIntervalSince1970,
                      "childID": childIDCustomer,
                      "childIDLastActivity": childIDLastActivity,
                      "childIDLastPeriod": childIDLastPeriod,
                      "childIDLastDiscount":childIDLastDiscount] as [String : Any]
        
        saveNewMembership(datos: status, path: "statusData:\(childIDCustomer)")
        saveNewMembership(datos: sell, path: "statusData:\(childIDCustomer):sells")
        saveNewMembership(datos: sell, path: "sells")
    }
    
    func saveNewMembership(datos: [String: Any], path: String) {
        ServerManager.Update(path: path, json: datos) { (data, error) in
            guard error == nil else {
                print("error")
                return
            }
            print("succes")
        }
    }
    
    func prepareSell(childID: String) -> [String : Any] {
        let fromDate = _view.getFromDate()
        let toDate = _view.getToDate()
        let childIDActivity = model.selectedActivity?.childID
        let childIDPeriod = model.selectedPeriod?.childID
        let childIDDiscount = model.selectedDiscount?.childID
        let price = model.selectedPeriod?.price
        let discount = model.selectedDiscount?.multiplier
        let childIDCustomer = model.selectedCustomer.childID
        
        let sell = [childID:["childID" : childID,
                             "childIDCustomer" : childIDCustomer,
                             "createdAt" : Date().timeIntervalSince1970,
                             "fromDate" : fromDate.timeIntervalSince1970,
                             "toDate" : toDate.timeIntervalSince1970,
                             "price" : price,
                             "childIDActivity" : childIDActivity!,
                             "childIDPeriod" : childIDPeriod!,
                             "childIDDiscount" : childIDDiscount ?? "",
                             "discount" : discount ?? 1.0]]
            as [String : Any]
        
        return sell
    }
    
    func getActivities() -> [ActivityModel] {
        return model.activities
    }
    
    func setSelectedActivity(row: Int) {
        if row == -1 {
            model.selectedActivity = nil
            model.filteredPeriods = [PeriodModel]()
            _view.reloadPeriod()
            _ = validate()
            
            return
        }
        model.selectedActivity = model.activities[row]
        
        model.filteredPeriods = model.periods.filter({$0.childIDActivity == model.selectedActivity!.childID})
        
        _view.reloadPeriod()
        _ = validate()
    }
    
    func setSelectedPeriod(row: Int) {
        if row == -1 {
            model.selectedPeriod = nil
            _ = validate()
            
            return
        }
        model.selectedPeriod = model.periods[row]
        estimateToDate()
        
        _ = validate()
        
    }
    
    func setSelectedDiscount(row: Int) {
        if row == 0 {
            model.selectedDiscount = nil
        } else {
            model.selectedDiscount = model.discounts[row - 1]
        }
    }
    
    func estimateToDate() {
        
        if model.selectedPeriod == nil {
            _view.setToDate(date: Date())
            return
        }
        let selectedPeriod = model.selectedPeriod
        let days = selectedPeriod?.days
        let fromDate = _view.getFromDate()
        _view.setToDate(date: Calendar.current.date(byAdding: .day, value: days!, to: fromDate)!)
     }
    
    func validate() -> Bool {
        var result = true
        if model.selectedActivity == nil {
            result = false
        }
        if model.selectedPeriod == nil {
            _view.disableDates()
            result = false
        }
        _view.enableDates()
        let amount = _view.getAmount()
        if let amountDouble = Double(amount) {
            if amountDouble < 0 && amountDouble > 1000000 {
                result = false
            }
        } else {
            result = false
        }
        
        if result {
            _view.enableSaveButton()
        } else {
            _view.disableSaveButton()
        }
        
        return result
    }
    
    func getFilteredPeriods() -> [PeriodModel] {
        return model.filteredPeriods
    }
    
    func getDiscountTitles() -> [String] {
        let titles = model.discounts.map({$0.name})
        return titles
    }
    
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?) {
        model.selectedStatus = selectedStatus
        model.selectedCustomer = selectedCustomer
    }
    
    func autoSelectActivity() {
        for (x,i) in (model!.activities).enumerated() {
            if i.childID == model.selectedStatus?.childIDLastActivity {
                model.selectedActivity = i
                _view.selectActivityManually(position: x)
            }
        }
    }
    
}
