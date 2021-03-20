//
//  CrudViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 27/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class CrudViewController : NSViewController {
    var mainOptionView : CrudMainMenuView!
    var crudExpenseView: CrudExpenseView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        createOptionView()
        createExpenseView()
    }
    
    private func createOptionView() {
        let frame = CGRect(x: 16, y: 16, width: 200, height: self.view.frame.height - 100)
        mainOptionView = CrudMainMenuView(frame: frame)
        view.addSubview(mainOptionView)
    }
    
    private func createExpenseView() {
        let frame = CGRect(x: 216, y: 16, width: 200, height: self.view.frame.height - 100)
        crudExpenseView = CrudExpenseView(frame: frame)
        view.addSubview(crudExpenseView)
    }
}

