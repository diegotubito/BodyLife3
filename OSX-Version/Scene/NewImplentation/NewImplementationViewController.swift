//
//  NewImplementationViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 22/12/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class NewImplementationViewController: NSViewController {
    var collapsable : CollapsableView!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
    }
    
    override func viewDidAppear() {
        super .viewDidAppear()
        createCollapsableTableView()
    }
    
    private func createCollapsableTableView() {
        collapsable = CollapsableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        view.addSubview(collapsable)
    }
}
