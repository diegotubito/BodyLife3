//
//  CrudExpenseView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 20/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class CrudExpenseView: SingleLabelTableView {
    override func commonInit() {
        super .commonInit()
        items = loadItems()
        
    }
    
    func loadItems() -> [[String: Any]] {
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: Bundle(for: CrudViewController.self), forName: "MainOptionItems"),
            let items = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        else { return [] }
        
        return items
    }
}
