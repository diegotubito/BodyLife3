//
//  ExpenseListView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 20/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

protocol ExpenseListViewDelegate: class {
    func selectedRow(row: Int)
}

class ExpenseListView: SingleLabelTableView {
    var fromDate: Date!
    var toDate: Date!
    
    var expenseDelegate: ExpenseListViewDelegate?
    
    override func commonInit() {
        super .commonInit()
    }
   
    func setDates(fromDate: Date, toDate: Date) {
        self.fromDate = fromDate
        self.toDate = toDate
        loadExpenses()
    }
    
    func loadExpenses() {
        let endpoint = Endpoint.Create(to: .Expense(.Load(fromDate: fromDate.timeIntervalSince1970, toDate: toDate.timeIntervalSince1970)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ExpenseModel.Populated]>) in
            guard
                let data = response.data,
                let jsonArrayData = try? JSONEncoder().encode(data),
                let jsonArray = try? JSONSerialization.jsonObject(with: jsonArrayData, options: []) as? [[String: Any]]
            else { return }
            DispatchQueue.main.async {
                self.items = jsonArray
                self.tableView.reloadData()
                self.tableView.deselectAll(self)
            }
        } fail: { (errorMessage) in
            print(errorMessage)
        }
    }
}

extension ExpenseListView {
    override func selectedRow(row: Int) {
        expenseDelegate?.selectedRow(row: row)
    }
}
