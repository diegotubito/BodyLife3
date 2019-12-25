//
//  SaveButtonCustomView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class SaveButtonCustomView: NSView {
    @IBOutlet weak var myView : NSView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var buttonView: NSView!
    @IBOutlet weak var myIndicator: NSProgressIndicator!
    var onButtonPressed : (() -> ())?
    var isEnabled = true {
        didSet {
            self.alphaValue = isEnabled ? 1.0 : 0.3
        }
    }
    var title : String! {
        didSet {
            titleLabel.stringValue = title
        }
    }
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SaveButtonCustomView", owner: self, topLevelObjects: nil)
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        myView.frame = frame
        self.addSubview(myView)
        
        buttonView.wantsLayer = true
        buttonView.layer?.cornerRadius = self.frame.height / 2
        buttonView.layer?.borderColor = NSColor.blue.cgColor
        buttonView.layer?.borderWidth = 1

        
        buttonView.layer?.backgroundColor = Constants.Colors.Blue.blueWhale.cgColor
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(buttonPressed))
        self.addGestureRecognizer(clickGesture)
    }
    
    @objc func buttonPressed() {
        if isEnabled {
            onButtonPressed?()
        }
    }
    
    func showLoading() {
        titleLabel.stringValue = ""
        myIndicator.startAnimation(nil)
  
    }
    
    func hideLoading() {
        titleLabel.stringValue = title
        myIndicator.stopAnimation(nil)
    }
    
}
