//
//  ExpenseListView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 20/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class ExpenseListView: SingleLabelTableView {
    override func commonInit() {
        super .commonInit()
        loadExpenses()
    }
    
    func loadExpenses() {
        let endpoint = Endpoint.Create(to: .Expense(.Load(fromDate: 0, toDate: 0)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ExpenseModel.Populated]>) in
            guard
                let data = response.data,
                let jsonArrayData = try? JSONEncoder().encode(data),
                let jsonArray = try? JSONSerialization.jsonObject(with: jsonArrayData, options: []) as? [[String: Any]]
            else { return }
            self.items = jsonArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } fail: { (errorMessage) in
            print(errorMessage)
        }
    }
    
}
