//
//  CrudViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 27/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class CrudViewController : NSViewController {
    var mainOptionView : SingleLabelTableView!
    var secondaryOptionView: SingleLabelTableView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        createOptionView()
        createSecondaryView()
    }
    
    private func createOptionView() {
        let frame = CGRect(x: 16, y: 16, width: 200, height: self.view.frame.height - 100)
        let column = loadUIConfiguration()
        let items = loadItems()
        
        mainOptionView = SingleLabelTableView(frame: frame)
        mainOptionView.setValues(items: items, column: column!)
        view.addSubview(mainOptionView)
    }
    
    private func createSecondaryView() {
        let frame = CGRect(x: 216, y: 16, width: 400, height: self.view.frame.height - 100)
        let column = loadUIConfiguration()
        let items = loadItems()

        secondaryOptionView = SingleLabelTableView(frame: frame)
        secondaryOptionView.setValues(items: items, column: column!)
        view.addSubview(secondaryOptionView)
    }
    
    
    private func loadUIConfiguration() -> GenericTableViewColumnModel? {
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: Bundle(for: CrudViewController.self), forName: "MainOptionViewUIConfig"),
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

