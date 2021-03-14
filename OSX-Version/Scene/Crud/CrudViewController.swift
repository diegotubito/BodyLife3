//
//  CrudViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 27/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class CrudViewController : NSViewController {
    var mainOptionView : MainOptionView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        createOptionView()
    }
    
    private func createOptionView() {
        mainOptionView = MainOptionView(frame: CGRect(x: 16, y: 16, width: 500, height: self.view.frame.height - 100))
        view.addSubview(mainOptionView)
    }
}

