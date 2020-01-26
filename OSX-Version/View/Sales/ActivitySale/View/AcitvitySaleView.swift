//
//  AcitvitySaleView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivitySaleView : XibViewBlurBackground, ActivitySaleViewContract {
    @IBOutlet var containerView: NSView!
    
    var viewModel : ActivitySaleViewModelContract!
    
    override func commonInit() {
        super .commonInit()
        
        viewModel = ActivitySaleViewModel(withView: self)
        
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.orange.cgColor
        
     //   addObserver()
    }
    
    private func addObserver() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(backTouched))
        containerView.addGestureRecognizer(clickGesture)
    }
    
   
    @objc private func backTouched() {
        print("touched")
    }
}
