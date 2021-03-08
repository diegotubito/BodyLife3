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
        viewmodel = MainOptionViewModel(withView: self)
        viewmodel.loadData()
    }
    
    func showSuccess(data: MainOptionModel.DataModel) {
        DispatchQueue.main.async {
            self.items = data.items
            self.columns = data.columns
            self.tableView.reloadData()
        }
    }
}

