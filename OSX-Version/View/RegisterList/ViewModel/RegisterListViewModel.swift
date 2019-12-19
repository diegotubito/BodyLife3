//
//  RegisterListViewModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 14/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListViewModel: RegisterListViewModelContract {
    var _view : RegisterListViewContract!
    var model : RegisterListModel!
    
    required init(withView view: RegisterListViewContract) {
        _view = view
        model = RegisterListModel()
    }
    
    func loadData() {
        _view.showLoading()
        model.registers.removeAll()
        let path = Paths.customerFull + ":personal:\(model.selectedCustomer.childID):sells"
        ServerManager.ReadJSON(path: path) { (json, error) in
            self._view.hideLoading()
        
            guard let json = json else {
                self._view.displayData()
                return
            }
            
            var jsonArray = ServerManager.jsonArray(json: json)
            for (x,register) in jsonArray.enumerated() {
                if let payments = register["payments"] {
                    let paymentJSONArray = ServerManager.jsonArray(json: payments as! [String : Any])
                    jsonArray[x]["payments"] = paymentJSONArray
                }
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let registers = try JSONDecoder().decode([SellRegisterModel].self, from: data)
                self.model.registers = registers
                self._view.displayData()
                
            } catch {
                self._view.showError(value: error.localizedDescription)
            }
        }
    }
    
    func setSelectedCustomer(customer: CustomerModel) {
        model.selectedCustomer = customer
        loadData()
    }
    
    func getRegisters() -> [SellRegisterModel] {
        return model.registers
    }
    
}
