//
//  MainOptionsView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class MainOptionView: GenericTableView {
    var viewmodel : MainOptionViewModelProtocol!
    
    override func commonInit() {
        super .commonInit()
        viewmodel = MainOptionViewModel(withView: self)
        viewmodel.loadData()
    }
}

extension MainOptionView : MainOptionViewProtocol{
    func showSuccess(data: MainOptionModel.DataModel) {
        print(data)
    }
}
