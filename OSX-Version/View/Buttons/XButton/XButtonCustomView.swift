//
//  XButtonCustomView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class XButtonCustomView: NSView {
    @IBOutlet weak var myView : NSView!
    @IBOutlet weak var buttonView: NSView!
    var didButtonPressed : (() -> ())?
    
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("XButtonCustomView", owner: self, topLevelObjects: nil)
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        myView.frame = frame
        self.addSubview(myView)
        
        buttonView.wantsLayer = true
        buttonView.layer?.cornerRadius = self.frame.height / 10
        buttonView.layer?.borderColor = Constants.Colors.Red.cinnabar.cgColor
        buttonView.layer?.borderWidth = 1
        
        
        buttonView.layer?.backgroundColor = Constants.Colors.Red.cinnabar.withAlphaComponent(0.4).cgColor
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(buttonPressed))
        self.addGestureRecognizer(clickGesture)
        
    }
    
    @objc func buttonPressed() {
        didButtonPressed?()
    }
}
