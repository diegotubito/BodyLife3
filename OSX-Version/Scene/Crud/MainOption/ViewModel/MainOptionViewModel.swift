//
//  MainOptionViewModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 28/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class MainOptionViewModel: MainOptionViewModelProtocol {
    var _view : MainOptionViewProtocol!
    var model : MainOptionModel!
    
    required init(withView: MainOptionViewProtocol) {
        _view = withView
        model = MainOptionModel()
    }
    
    private func loadUIConfiguration() -> GenericTableViewColumnModel? {
        guard let data = readLocalFile(forName: "MainOptionViewUIConfig"),
              let column = try? JSONDecoder().decode(GenericTableViewColumnModel.self, from: data) else {
            return nil
        }
        return column
    }
    
    func loadData() {
        guard let column = loadUIConfiguration() else { return }
        
        guard let data = readLocalFile(forName: "MainOptionItems"),
              let items = try? JSONDecoder().decode([MainOptionModel.Item].self, from: data) else {
            return
        }
        model.data = MainOptionModel.DataModel(column: column,
                                               items: items)
        _view.showSuccess(data: model.data)
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        let bundle = Bundle(for: MainOptionViewModel.self)
        guard
            let bundlePath = bundle.path(forResource: name, ofType: "json"),
            let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8)
        else { return nil }
        
        return jsonData
    }
    
}
