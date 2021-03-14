//
//  MainOptionsView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class MainOptionView: GenericTableView<SingleLabelItem, MainOptionModel.Item>, MainOptionViewProtocol {
    var viewmodel : MainOptionViewModelProtocol!
    
    override func commonInit() {
        super .commonInit()
        self.delegate = self
        viewmodel = MainOptionViewModel(withView: self)
        viewmodel.loadData()
    }
    
    func showSuccess(data: MainOptionModel.DataModel) {
        DispatchQueue.main.async {
            self.items = data.items
            self.column = data.column
            self.tableView.reloadData()
        }
    }
}

extension MainOptionView: GenericTableViewDelegate {
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        print("heeeey \(stringValue)")
        print(tableView.selectedRow)
        print(tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnIdentifier)))
        print(columnIdentifier)
    }
}
