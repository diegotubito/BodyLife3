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
        column = loadColumn()!
        showItems()
    }
    
    func showItems() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    private func loadColumn() -> GenericTableViewColumnModel? {
        let className = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: bundle, forName: className),
            let column = try? JSONDecoder().decode(GenericTableViewColumnModel.self, from: data)
        else { return nil }
        
        return column
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
