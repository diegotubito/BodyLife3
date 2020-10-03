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
    
    func setCustomerStatus(selectedCustomer: CustomerModel.Customer) {
        model.selectedCustomer = selectedCustomer
    }
    
    func loadPeriods() {
        _view.showLoading()
        
        let url = "http://127.0.0.1:2999/v1/period"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            self._view.hideLoading()
            guard let data = data else {
               
                return
            }
            do {
                let response = try JSONDecoder().decode(PeriodModel.ViewModel.self, from: data)
                self.parseActivityAndDiscount(response: response)
            } catch {
                return
            }
        }
    }
    
    func loadDiscounts() {
        _view.showLoading()
        
        let url = "http://127.0.0.1:2999/v1/discount"
        
        let _service = NetwordManager()
        _service.get(url: url) { (data, error) in
            self._view.hideLoading()
            guard let data = data else {
               
                return
            }
            do {
                let response = try JSONDecoder().decode(DiscountModel.ViewModel.self, from: data)
                self.model.discounts = response.discounts
                self._view.showDiscounts()
            } catch {
                return
            }
        }
    }
    
    func parseActivityAndDiscount(response : PeriodModel.ViewModel) {
        let activities = response.periods.compactMap { $0.activity }
        
        var uniqueArray = [ActivityModel.NewRegister]()
        for i in activities {
            if !uniqueArray.contains(where: {$0._id == i._id}) {
                uniqueArray.append(i)
            }
        }
        let filterActivities = uniqueArray.filter({$0.isEnabled})
        let sortedActivities = filterActivities.sorted(by: { $0.timestamp > $1.timestamp })
        model.activities = sortedActivities
        
        let filterPeriods = response.periods.filter({$0.isEnabled})
        let sortedPeriods = filterPeriods.sorted(by: {$0.days < $1.days})
        model.periods = sortedPeriods
        _view.showActivities()
        _view.showPeriods()
    }
    
    func selectTypeAutomatically() {
//        let childIDLastType = model.selectedStatus?.childIDLastType
//        let availableTypes = getTypes()
//        let lastType = availableTypes.filter({$0.childID == childIDLastType})
//        if lastType.count == 1 {
//            _view.setPopupTypeByTitle(lastType[0].name)
//            model.selectedType = lastType[0]
//            _view.showActivities()
//            return
//        }
//        model.selectedType = nil
//        _view.setPopupTypeByTitle(nil)
//        _view.showActivities()
    }
    
    
    
    func selectDiscountAutomatically() {
//        let childIDLastDiscount = model.selectedStatus?.childIDLastDiscount
//        let availableDiscounts = getDiscounts()
//        let lastDiscount = availableDiscounts.filter({$0.childID == childIDLastDiscount})
//        if lastDiscount.count == 0 {return}
//        if lastDiscount.count == 1 {
//            _view.setPopupDiscountByTitle(lastDiscount[0].name)
//            model.selectedDiscount = lastDiscount[0]
//            return
//        }
//        model.selectedDiscount = availableDiscounts[0]
//        _view.setPopupDiscountByTitle(availableDiscounts[0].name)
    }
    
    func setSelectedActivity(_ value: ActivityModel.NewRegister?) {
        model.selectedActivity = value
    }
    
    func setSelectedPeriod(_ value: PeriodModel.AUX_Period?) {
        model.selectedPeriod = value
    }
    
    func getSelectedDiscount() -> DiscountModel.NewRegister? {
        return model.selectedDiscount
    }
    
    func getSelectedActivity() -> ActivityModel.NewRegister? {
        return model.selectedActivity
    }
    
    func getSelectedPeriod() -> PeriodModel.AUX_Period? {
        return model.selectedPeriod
    }
    
    func getProperFromDate() -> Date {
        guard let expiration = model.statusInfo?.expiration else {
            return Date()
        }
        
        guard let days = expiration.diasTranscurridos(fecha: Date()), days < 16 else {
            return Date()
        }
        
        return expiration
    }
    
    
    func getTotals() -> (amount: Double, amountDiscounted: Double) {
        let multiplier = model.selectedDiscount?.factor ?? 0.0
        let price = model.selectedPeriod?.price ?? 0.0
        let discount = multiplier * price
        return (price, discount)
    }
    
    func getPeriods() -> [PeriodModel.AUX_Period] {
        let filter = model.periods.filter({$0.activity?._id == model.selectedActivity?._id})
        
        return filter
    }
    
    func getActivities() -> [ActivityModel.NewRegister] {
        return model.activities
    }
    
    func getDiscounts() -> [DiscountModel.NewRegister] {
        return model.discounts
    }
    
    func setStatusInfo(_ statusInfo: CustomerStatusModel.StatusInfo?) {
        model.statusInfo = statusInfo
    }
    
}



//MARK: SAVE METHODS
extension ActivitySaleViewModel {
    
    func save() {
  /*      let childIDCustomer = model.selectedCustomer.childID
        let childIDNew = ServerManager.createNewChildID()
        let statusJSON = prepareStatus(childID: childIDNew)
        let sellJSON = prepareSell(childID: childIDNew)
        let statusPath = "\(Paths.customerStatus):\(childIDCustomer)"
        let statusPathSell = "\(Paths.fullPersonalData):\(childIDCustomer):sells"
        let statusPathTransaction = "\(Paths.customerStatus):\(childIDCustomer)"
        let pathSell = Paths.registers
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
 */
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

    func prepareSell(childID: String) -> [String : Any] {
      
        return [String : Any]()
    }
    
    func validate() -> Bool {
        var result = true
        if model.selectedPeriod == nil || model.selectedActivity == nil {
            result = false
        }
        return result
    }
    
    func selectActivity(_ value: Int) {
        model.selectedActivity = model.activities[value]
        _view.showPeriods()
    }
    
    func selectDiscount(_ value: Int) {
        if value == -1 {
            model.selectedDiscount = nil
            
        } else {
            model.selectedDiscount = model.discounts[value]
        }
    }
    
  
   
}
