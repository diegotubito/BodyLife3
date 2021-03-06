//
//  ActivitySaleViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

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
        let request = Endpoint.Create(to: .Period(.LoadAll))
        BLServerManager.ApiCall(endpoint: request) { (response:ResponseModel<[PeriodModel.Populated]>) in
            self._view.hideLoading()
            guard let periods = response.data else {
                return
            }
            self.parseActivityAndDiscount(periods: periods)
        } fail: { (error) in
            self._view.hideLoading()
            self._view.showError(error)
        }
    }
    
    func loadDiscounts() {
        _view.showLoading()
        let endpoint = Endpoint.Create(to: .Discount(.LoadAll))
        BLServerManager.ApiCall(endpoint: endpoint) { (result:ResponseModel<[DiscountModel.Register]>) in
            self._view.hideLoading()
            guard let discounts = result.data else {
                return
            }
            self.model.discounts = discounts
            self._view.showDiscounts()
        } fail: { (error) in
            self._view.hideLoading()
        }
    }
    
    func parseActivityAndDiscount(periods : [PeriodModel.Populated]) {
        let activities = periods.compactMap { $0.activity }
        
        var uniqueArray = [ActivityModel.NewRegister]()
        for i in activities {
            if !uniqueArray.contains(where: {$0._id == i._id}) {
                uniqueArray.append(i)
            }
        }
        let filterActivities = uniqueArray.filter({$0.isEnabled})
        let sortedActivities = filterActivities.sorted(by: { $0.timestamp > $1.timestamp })
        model.activities = sortedActivities
        
        let filterPeriods = periods.filter({$0.isEnabled})
        let sortedPeriods = filterPeriods.sorted(by: {$0.days < $1.days})
        model.periods = sortedPeriods
        _view.showActivities()
        _view.showPeriods()
    }
    
    func selectActivityAutomatically() {
        let activityId = model.statusInfo?.lastActivityId
        let availableActivities = model.activities
        let lastActivity = availableActivities.filter({$0._id == activityId})
        if lastActivity.count == 1 {
            _view.setPopupActivitydByTitle(lastActivity[0].description)
            model.selectedActivity = lastActivity[0]
            return
        }
        model.selectedActivity = nil
        _view.setPopupActivitydByTitle(nil)
    }
    
    func selectDiscountAutomatically() {
        if model.statusInfo?.lastDiscountId == nil {
            _view.setPopupDiscountByTitle("Sin Descuento")
            model.selectedDiscount = nil
            return
        }
        let discountId = model.statusInfo?.lastDiscountId
        let availableDiscounts = getDiscounts()
        let lastDiscount = availableDiscounts.filter({$0._id == discountId})
        if lastDiscount.count == 0 {
            return
        }
        if lastDiscount.count == 1 {
            _view.setPopupDiscountByTitle(lastDiscount[0].description)
            model.selectedDiscount = lastDiscount[0]
            return
        }
        model.selectedDiscount = availableDiscounts[0]
        _view.setPopupDiscountByTitle(availableDiscounts[0].description)
    }
    
    func setSelectedActivity(_ value: ActivityModel.NewRegister?) {
        model.selectedActivity = value
    }
    
    func setSelectedPeriod(_ value: PeriodModel.Populated?) {
        model.selectedPeriod = value
    }
    
    func getSelectedDiscount() -> DiscountModel.Register? {
        return model.selectedDiscount
    }
    
    func getSelectedActivity() -> ActivityModel.NewRegister? {
        return model.selectedActivity
    }
    
    func getSelectedPeriod() -> PeriodModel.Populated? {
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
        var multiplier = 1 - (model.selectedDiscount?.factor ?? 0.0)
        if multiplier == 1 {
            multiplier = 0
        }
        
        let price = model.selectedPeriod?.price ?? 0.0
        let discount = multiplier * price
        return (price, discount)
    }
    
    func getPeriods() -> [PeriodModel.Populated] {
        let filter = model.periods.filter({$0.activity?._id == model.selectedActivity?._id})
        
        return filter
    }
    
    func getActivities() -> [ActivityModel.NewRegister] {
        return model.activities
    }
    
    func getDiscounts() -> [DiscountModel.Register] {
        return model.discounts
    }
    
    func setStatusInfo(_ statusInfo: CustomerStatusModel.StatusInfo?) {
        model.statusInfo = statusInfo
    }
}

//MARK: SAVE METHODS
extension ActivitySaleViewModel {
    
    func save(fromDate: Date, toDate: Date, price: Double, priceList: Double) {
        _view.disableSaveButton()
        _view.showLoadingButton()
        let dicountID : String? = model.selectedDiscount?._id
        let activityID : String = model.selectedActivity!._id
        let periodID : String = model.selectedPeriod!._id
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = model.statusInfo?.customer._id ?? ""
        let activityDescription = model.selectedActivity?.description ?? ""
        let periodDescription = model.selectedPeriod?.description ?? ""
        let description = activityDescription + " - " + periodDescription
        let newRegister = SellModel.Register(customer: customerId,
                                                discount: dicountID,
                                                activity: activityID,
                                                article: nil,
                                                period: periodID,
                                                timestamp: createdAt,
                                                fromDate: fromDate.timeIntervalSince1970,
                                                toDate: toDate.timeIntervalSince1970,
                                                quantity: nil,
                                                isEnabled: true,
                                                productCategory: ProductCategory.activity.rawValue,
                                                price: price,
                                                priceList: priceList,
                                                priceCost: nil,
                                                description: description)
        
        let body = encodeSell(newRegister)
        let endpoint = Endpoint.Create(to: .Sell(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response:ResponseModel<SellModel.Register>) in
            let _id = response.data?._id
            self.addNullPayment(sellId: _id!)
        } fail: { (error) in
            self._view.showError("No se puedo guardar venta \(error)")
            self._view.enableSaveButton()
            self._view.hideLoadingButton()
        }
    }
    
    private func addNullPayment(sellId: String) {
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = model.statusInfo?.customer._id ?? ""

        let newRegister = PaymentModel.Register(customer: customerId,
                                                sell: sellId,
                                                isEnabled: true,
                                                timestamp: createdAt,
                                                paidAmount: 0,
                                                productCategory: ProductCategory.activity.rawValue)
        let body = encodePayment(newRegister)
        let endpoint = Endpoint.Create(to: .Payment(.Save(body: body)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<PaymentModel.Register>) in
            self._view.hideLoading()
            self._view.showSuccessSaving()
            self._view.hideLoadingButton()
        } fail: { (error) in
            self._view.hideLoading()
            self._view.showError("No se puedo guardar pago nulo")
            self._view.enableSaveButton()
            self._view.hideLoadingButton()
        }
    }
   
    
    private func encodeSell(_ register: SellModel.Register) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
    
    private func encodePayment(_ register: PaymentModel.Register) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
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
    }
    
    func selectDiscount(_ value: Int) {
        if value == -1 {
            model.selectedDiscount = nil
            
        } else {
            model.selectedDiscount = model.discounts[value]
        }
    }
    
    func setFromDate() {
        guard let expiration = model.statusInfo?.expiration else {
            model.fromDate = Date()
            _view.showFromDate(value: model.fromDate)
            return
        }
        
        if let days = expiration.diasTranscurridos(fecha: Date()) {
            if days > 15 {
                model.fromDate = Date()
            } else {
                model.fromDate = expiration
            }
        } else {
            model.fromDate = Date()
        }
        _view.showFromDate(value: model.fromDate)
    }
    
    func setEndDate() {
        guard let selectedPeriod = model.selectedPeriod else {
            model.endDate = model.fromDate
            _view.showEndDate(value: model.endDate)
            return
        }
        
        let days = selectedPeriod.days
        let fromDate = model.fromDate
        let myCalendar = Calendar(identifier: .gregorian)
        let endDate = myCalendar.date(byAdding: .day, value: days, to: fromDate)
        model.endDate = endDate!
        
        _view.showEndDate(value: model.endDate)
    }
    
    func setFromDate(value: Date) {
        model.fromDate = value
        setEndDate()
    }

}
