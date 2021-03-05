//
//  MainOptionViewModelProtocol.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol MainOptionViewModelProtocol {
    init(withView: MainOptionViewProtocol)
    func loadData()
}

protocol MainOptionViewProtocol {
    func showSuccess(data: MainOptionModel.DataModel)
}
