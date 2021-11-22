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
    }
    
    init(frame: CGRect, columns: [String: Any]?) {
        super.init(frame: frame)
        if let column = columns {
            loadColumn(from: column)
        } else {
            loadColumn()
        }
        showItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showItems() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.deselectAll(nil)
        }
    }
    
    public func loadColumn(from dictionary: [String: Any]) {
        guard
            let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
            let column = try? JSONDecoder().decode(GenericTableViewColumnModel.self, from: data)
        else { fatalError("Error al cargar las columnas en: \(dictionary)") }
        
        self.column = column
    }
   
    public func loadColumn() {
        let className = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: bundle, forName: className),
            let column = try? JSONDecoder().decode(GenericTableViewColumnModel.self, from: data)
        else { fatalError("Error al cargar las columnas en: \(className).json") }
        
        self.column = column
    }
}
