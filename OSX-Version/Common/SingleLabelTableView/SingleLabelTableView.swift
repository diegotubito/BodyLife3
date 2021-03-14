//
//  MainOptionsView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class SingleLabelTableView: GenericTableView<SingleLabelTableViewItem> {
    
    override func commonInit() {
        super .commonInit()
        self.delegate = self
        showItems()
    }
    
    func setValues(items: [[String: Any]], column: GenericTableViewColumnModel) {
        self.items = items
        self.column = column
        showItems()
    }
    
    func showItems() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SingleLabelTableView: GenericTableViewDelegate {
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        print("heeeey \(stringValue)")
        print(tableView.selectedRow)
        print(tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnIdentifier)))
        print(columnIdentifier)
    }
}
