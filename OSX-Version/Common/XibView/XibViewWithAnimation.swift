//
//  XibViewWithAnimation.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class XibViewWithAnimation: NSView {
    var xibName : String?
    var errorNoConnection : NSImageView!

    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
        commonInit()
    }
    
    func showErrorConnectionView() {
        errorNoConnection = NSImageView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        errorNoConnection.image = #imageLiteral(resourceName: "NoConnection")
        errorNoConnection.wantsLayer = true
        errorNoConnection.Blur()
        self.addSubview(errorNoConnection)
    
    }
    
    func removeErrorConnectionView() {
        if errorNoConnection != nil {
            errorNoConnection.removeFromSuperview()
        }
    }
    
    internal func commonInit() {
        let xibName = self.xibName ?? String(describing: type(of: self))
        
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed(xibName, owner: self, topLevelObjects: &topLevelObjects) {
            if let myView = topLevelObjects?.first(where: { $0 is NSView } ) as? NSView {
                myView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
                addSubview(myView)
            }
        }
        
    }
    
    deinit {
        
    }
    
    func removeView() {
        self.removeFromSuperview()
    }
    
    enum Animations: CaseIterable {
        case fadeIn
        case fadeOut
        case rightIn
        case rightOut
        case leftIn
        case leftOut
        case none
    }
    
    var animateMode : Animations = .none {
        didSet {
            animateStart()
        }
    }
    
    func animateStart() {
        switch animateMode {
        case .fadeIn:
            isHidden = false
            Fade(type: ._in) {
            }
            break
        case .fadeOut:
            Fade(type: ._out) {
                self.isHidden = true
            }
            break
        case .none:
            break
        case .rightIn:
            isHidden = false
            Move(type: .fromRight) {
            }
        case .rightOut:
            Move(type: .fromRight) {
                self.isHidden = true
                
            }
        case .leftIn:
            isHidden = false
            Move(type: .fromRight) {
                
            }
        case .leftOut:
            Move(type: .fromRight) {
                self.isHidden = true
                
            }
        }
    }
    
}


extension XibViewWithAnimation: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let name = anim.value(forKey: "name") as? String else {
            return
        }
        
        switch name {
        case "Fade":
            // let layer = anim.value(forKey: "layer") as? CALayer
            let animation = anim.value(forKey: "animation") as? MyBasicAnimation
            animation?.didFinished!()
            break
        case "Move":
            // let layer = anim.value(forKey: "layer") as? CALayer
            let animation = anim.value(forKey: "animation") as? MyBasicAnimation
            animation?.didFinished!()
            break
        default:
            break
        }
    }
    
    enum FadeType {
        case _in
        case _out
    }
    
    func Fade(type: FadeType, completion: @escaping () -> ()) {
        var from = 0
        var to = 1
        if type == ._out {
            from = 1
            to = 0
        }
        let animation = MyBasicAnimation(keyPath: "opacity")
        animation.fromValue = from
        animation.toValue = to
        animation.delegate = self
        animation.duration = 0.5
        animation.repeatCount = 0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = false
        animation.setValue("Fade", forKey: "name")
        animation.setValue(layer, forKey: "layer")
        animation.setValue(animation, forKey: "animation")
        self.layer?.add(animation, forKey: nil)
        animation.didFinished = {
            completion()
        }
    }
    
    enum MoveType {
        case fromLeft
        case fromRight
        case fromTop
        case fromBottom
    }
    
    func Move(type: MoveType, completion: @escaping () -> ()) {
        var key = "position.x"
        if type == .fromTop || type == .fromBottom {
            key = "position.y"
        }
        var from : CGFloat = -self.frame.width
        var to : CGFloat = self.frame.origin.x
        if type == .fromRight {
            from = (self.superview?.frame.width)!
            to = self.frame.origin.x
        }
        
       
        let animation = MyBasicAnimation(keyPath: key)
        animation.fromValue = from
        animation.toValue = to
        animation.delegate = self
        animation.duration = 0.5
        animation.repeatCount = 0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = false
        animation.setValue("Move", forKey: "name")
        animation.setValue(layer, forKey: "layer")
        animation.setValue(animation, forKey: "animation")
        self.layer?.add(animation, forKey: nil)
        animation.didFinished = {
            completion()
        }
    }
    
    
}

class MyBasicAnimation: CABasicAnimation {
    var didFinished : (() -> ())?
}
