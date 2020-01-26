//
//  XibViewWithBlurBackground.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class XibViewBlurBackground: XibView {
    var backgroundView : NSView!
    var origin : CGPoint!
    var destiny : CGPoint!
    var closeWhenBackgroundIsTouch : Bool = true
    
    override func commonInit() {
        super .commonInit()
        origin = self.frame.origin
           
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.blue.cgColor
        addGestureToBackground()
     
    }
    
    func addGestureToBackground() {
        let click = NSClickGestureRecognizer(target: self, action: #selector(backgroundTouchedHandler))
        self.addGestureRecognizer(click)
    }
    
    @objc func backgroundTouchedHandler() {
        print("touch background")
    }

      
    private func createBackgroundView() {
        if backgroundView != nil {
            backgroundView.removeFromSuperview()
        }
        if let owner = superview {
            backgroundView = NSView(frame: CGRect(x: 0, y: 0, width: owner.frame.width, height: owner.frame.height))
            backgroundView.wantsLayer = true
            backgroundView.layer?.backgroundColor = NSColor.clear.cgColor
            backgroundView.Blur(intensity: 2)
            
            owner.addSubview(backgroundView, positioned: .below, relativeTo: self)
            
            addBackgroundGesture()

            
        }
    }
    
    func showView() {
        createBackgroundView()
        move(from: CGPoint(x: origin.x, y: origin.y), to: CGPoint(x: destiny.x, y: destiny.y))
        self.setFrameOrigin(NSPoint(x: destiny.x, y: destiny.y))
    }
    
    func hideView() {
        backgroundView.removeFromSuperview()
        move(from: CGPoint(x: destiny.x, y: destiny.y), to: CGPoint(x: origin.x, y: origin.y))
        self.setFrameOrigin(NSPoint(x: origin.x, y: origin.y))
    }
    
    private func move(from: CGPoint, to: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .both
        self.layer?.add(animation, forKey: nil)
        
    }
 
    @objc func backgroundTouched() {
        if closeWhenBackgroundIsTouch {
            hideView()
        }
    }
    
    private func addBackgroundGesture() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(backgroundTouched))
        backgroundView.addGestureRecognizer(clickGesture)
        
    }
    
}
