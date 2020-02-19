//
//  ActivitySaleViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivitySaleViewModel : ActivitySaleViewModelContract {
   
    var model: ActivitySaleModel!
    var _view : ActivitySaleViewContract!
    
    required init(withView view: ActivitySaleViewContract) {
        _view = view
        model = ActivitySaleModel()
    }
    
    func setCustomerStatus(selectedCustomer: CustomerModel, selectedStatus: CustomerStatus?) {
        model.selectedStatus = selectedStatus
        model.selectedCustomer = selectedCustomer
    }
    
    func loadServices() {
        let path = Paths.productService
        _view.showLoading()
       
        ServerManager.ReadJSON(path: path) { (json, error) in
            self._view.hideLoading()
            if error != nil {
                self._view.showError("Error al cargar los producto servicios")
                return
            }
            guard let json = json else {
                self._view.showError("Error al cargar los producto servicios")
                return
            }
            do {
                if let activityTypesJSON = json["type"] as? [String : Any] {
                    let activityTypeArray = ServerManager.jsonArray(json: activityTypesJSON)
                    let dataActivityType = try JSONSerialization.data(withJSONObject: activityTypeArray, options: [])
                    self.model.types = try JSONDecoder().decode([ServiceTypeModel].self, from: dataActivityType)
                }
                if let activityJSON = json["activity"] as? [String : Any] {
                    let activityArray = ServerManager.jsonArray(json: activityJSON)
                    let dataActivity = try JSONSerialization.data(withJSONObject: activityArray, options: [])
                    self.model.activities = try JSONDecoder().decode([ActivityModel].self, from: dataActivity)
                }
                if let discountJSON = json["discount"] as? [String : Any] {
                    let discountArray = ServerManager.jsonArray(json: discountJSON)
                    let dataDiscount = try JSONSerialization.data(withJSONObject: discountArray, options: [])
                    self.model.discounts = try JSONDecoder().decode([DiscountModel].self, from: dataDiscount)
                }
                self._view.showSuccess()
            } catch {
                self._view.showError("Error en serializacion producto servicios")
            }
        }
 
    }
    
    func getActivities() -> [ActivityModel] {
        
        guard let selectedType = model.selectedType else {
            return []
        }
        
        let filterByEnableActivities = model.activities.filter { (activity) -> Bool in
            return activity.isEnabled != false
        }
        
        let filterByType = filterByEnableActivities.filter({$0.childIDType == selectedType.childID})
        
        let sorted = filterByType.sorted(by: { $0.days < $1.days })
        
        return sorted
    }
    
    func getTypes() -> [ServiceTypeModel] {
        let types = model.types
        let enabledTypes = types.filter { (type) -> Bool in
            return type.isEnabled
        }
        let sorted = enabledTypes.sorted(by: { $0.name > $1.name })
        return sorted
    }
    
    func getDiscounts() -> [DiscountModel] {
        let discounts = model.discounts
        let enabled = discounts.filter { (discount) -> Bool in
            return discount.isEnabled
        }
        let sorted = enabled.sorted(by: { $0.name > $1.name })
        return sorted
    }
    
    func selectType(_ value: Int) {
        let types = getTypes()
        model.selectedType = types[value]
        _view.showActivities()
    }
    
    func selectDiscount(_ value: Int) {
        let discounts = getDiscounts()
        model.selectedDiscount = discounts[value]
    }
    
    func selectTypeAutomatically() {
        let childIDLastType = model.selectedStatus?.childIDLastType
        let availableTypes = getTypes()
        let lastType = availableTypes.filter({$0.childID == childIDLastType})
        if lastType.count == 1 {
            _view.setPopupTypeByTitle(lastType[0].name)
            model.selectedType = lastType[0]
            _view.showActivities()
            return
        }
        model.selectedType = nil
        _view.setPopupTypeByTitle(nil)
        _view.showActivities()
    }
    
    
    
    func selectDiscountAutomatically() {
        let childIDLastDiscount = model.selectedStatus?.childIDLastDiscount
        let availableDiscounts = getDiscounts()
        let lastDiscount = availableDiscounts.filter({$0.childID == childIDLastDiscount})
        if lastDiscount.count == 0 {return}
        if lastDiscount.count == 1 {
            _view.setPopupDiscountByTitle(lastDiscount[0].name)
            model.selectedDiscount = lastDiscount[0]
            return
        }
        model.selectedDiscount = availableDiscounts[0]
        _view.setPopupDiscountByTitle(availableDiscounts[0].name)
    }
    
    func setSelectedActivity(_ value: ActivityModel?) {
        model.selectedActivity = value
        _view.adjustDates()
    }
    
    func getSelectedActivity() -> ActivityModel? {
        return model.selectedActivity
    }
    
    func getProperFromDate() -> Date {
        let selectedStatus = model.selectedStatus
        if selectedStatus?.expiration == nil {
            return Date()
        }
        let expirationDate = selectedStatus?.expiration.toDate ?? Date()
        let dueToDays = expirationDate.diasTranscurridos(fecha: Date()) ?? 0
        if dueToDays > 15 {
            return Date()
        }
        return expirationDate
    }
    
    
    func getTotals() -> (price: Double, discount: Double) {
        let multiplier = model.selectedDiscount?.multiplier ?? 0.0
        let price = model.selectedActivity?.price ?? 0.0
        let discount = multiplier * price
        return (price, discount)
    }
    
    func getRemainingDays() -> String {
        var expDate = model.selectedStatus?.expiration.toDate ?? Date()
        if let activity = model.selectedActivity {
            expDate.addDays(valor: activity.days)
        }
        let days = expDate.diasTranscurridos(fecha: Date()) ?? 0
        return String(-days)
    }
    
    func getExpirationDate() -> String {
        var expDate = model.selectedStatus?.expiration.toDate
        if let activity = model.selectedActivity {
            if expDate == nil {
                expDate = Date()
            }
            expDate?.addDays(valor: activity.days)
        }
        let result = expDate?.toString(formato: "dd/MM/yyyy")
        return result ?? "-"
        
    }
}



//MARK: SAVE METHODS
extension ActivitySaleViewModel {
    
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
        
        updateSellCountForActivity((model.selectedActivity?.childID)!)
        
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
        
        let (price, discount) = getTotals()
        let amountToPay = price - discount
        saveNewTransaction(path: statusPathTransaction, value: -amountToPay)
        
        _view.showSuccessSaving()
    }
    
    private func updateSellCountForActivity(_ childIDActivity: String) {
        let path = "\(Paths.productActivity):\(childIDActivity)"
        ServerManager.Transaction(path: path, key: "sellCount", value: 1, success: {
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
        let childIDLastActivity = (model.selectedActivity?.childID) ?? ""
        let childIDLastDiscount = (model.selectedDiscount?.childID) ?? ""
        let status = ["surname" : surname,
                      "name": name,
                      "expiration": _view.getToDate().timeIntervalSinceReferenceDate,
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
        let (price, discount) = getTotals()
        let childIDCustomer = model.selectedCustomer.childID
        let sell = [childID:["childID" : childID,
                             "childIDCustomer" : childIDCustomer,
                             "createdAt" : Date().timeIntervalSinceReferenceDate,
                             "fromDate" : fromDate.timeIntervalSinceReferenceDate,
                             "toDate" : toDate.timeIntervalSinceReferenceDate,
                             "price" : price,
                             "discount" : discount,
                             "amountToPay" : (price - discount),
                             "isEnabled" : true,
                             "queryByDMY" : Date().queryByDMY,
                             "queryByMY" : Date().queryByMY,
                             "queryByY" : Date().queryByY,
                             "childIDLastType" : childIDLastType!,
                             "childIDLastActivity" : childIDLastActivity!,
                             "childIDLastDiscount" : childIDLastDiscount ?? "",
                             "displayName" : displayName]]
            as [String : Any]
        
        return sell
    }
    
    func validate() -> Bool {
        var result = true
        if model.selectedType == nil || model.selectedActivity == nil {
            result = false
        }
        return result
    }
    
}
