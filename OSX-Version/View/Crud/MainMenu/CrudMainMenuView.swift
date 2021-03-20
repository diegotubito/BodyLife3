//
//  CrudMainMenu.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 20/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

class CrudMainMenuView: SingleLabelTableView {
    
    override func commonInit() {
        super .commonInit()
        column = loadColumn()!
        items = loadItems()
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
    
    func loadItems() -> [[String: Any]] {
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: Bundle(for: CrudViewController.self), forName: "MainOptionItems"),
            let items = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        else { return [] }
        
        return items
    }
}
