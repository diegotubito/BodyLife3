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
    
    func loadData() {
        guard let data = readLocalFile(forName: "MainOptionView"),
              let value = try? JSONDecoder().decode(MainOptionModel.DataModel.self, from: data) else {
            return
        }
        
        model.data = value
        _view.showSuccess(data: value)
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            let bundle = Bundle(for: MainOptionViewModel.self)
            if let bundlePath = Bundle.main.path(forResource: name,
                                            ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                print(json)
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
}
