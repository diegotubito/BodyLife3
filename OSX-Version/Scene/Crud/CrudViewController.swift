//
//  CrudViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 27/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class CrudViewController : NSViewController {
    @IBOutlet weak var leftContainer: NSView!
    var mainOptionView : MainOptionView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
       
        self.createOptionView()
        
    }
    
    private func createOptionView() {
        mainOptionView = MainOptionView(frame: leftContainer.frame)
        leftContainer.addSubview(mainOptionView)
      
        
        mainOptionView.translatesAutoresizingMaskIntoConstraints = false
        mainOptionView.leftAnchor.constraint(equalTo: leftContainer.leftAnchor, constant: 0).isActive = true
        mainOptionView.rightAnchor.constraint(equalTo: leftContainer.rightAnchor, constant: 0).isActive = true
        mainOptionView.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor, constant: 0).isActive = true
        mainOptionView.topAnchor.constraint(equalTo: leftContainer.topAnchor, constant: 0).isActive = true
    }
}
