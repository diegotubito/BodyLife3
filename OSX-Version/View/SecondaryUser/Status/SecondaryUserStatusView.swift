//
//  SecondaryUserStatusView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    public static let userSecondaryUpdated = Notification.Name(rawValue: "userSecondaryUpdated")
    public static let needSecondaryUserLogin = Notification.Name(rawValue: "needSecondaryUserLogin")
}

class SecondaryUserStatusView: XibView {
    var expirationToken: NSTextField!
    var userNameLabel: NSTextField!
    var timer : Timer!
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
        createViews()
        NotificationCenter.default.addObserver(self, selector: #selector(secondaryUserUpdatedHandler), name: .userSecondaryUpdated, object: nil)
        updateValues()
    }
    
    func createViews() {
        self.layer?.borderWidth = 1
        self.layer?.borderColor = .white
        
        let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.orientation = .vertical
        self.addSubview(stack)
        
        userNameLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 10))
        userNameLabel.stringValue = ""
        userNameLabel.isEditable = false
        userNameLabel.textColor = .darkGray
        stack.addArrangedSubview(userNameLabel)
        
        expirationToken = NSTextField()
        expirationToken.stringValue = ""
        expirationToken.textColor = .darkGray
        expirationToken.isEditable = false
        
        expirationToken.font = NSFont.systemFont(ofSize: 10)
        
        let revokeButton = NSButton(title: "", target: self, action: #selector(revokeDidPressed))
        let attributedString = NSAttributedString(string: "Revocar",
                                                  attributes: [NSAttributedString.Key.foregroundColor : NSColor.darkGray,
                                                            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10)])
        revokeButton.attributedTitle = attributedString
       
        let revokeStack = NSStackView(frame: NSRect(x: 0, y: 0, width: stack.frame.width, height: 10))
        revokeStack.frame = NSRect(x: 0, y: 0, width: self.frame.width, height: 10)
        revokeStack.alignment = .leading
        revokeStack.distribution = .fillEqually
        revokeStack.orientation = .horizontal
        revokeStack.spacing = 0
        revokeStack.addArrangedSubview(expirationToken)
        revokeStack.addArrangedSubview(revokeButton)
        
        stack.addArrangedSubview(revokeStack)
    }
    
    @objc func revokeDidPressed() {
        timer.invalidate()
        SecondaryUserSession.Remove()
        NotificationCenter.default.post(name: .needSecondaryUserLogin, object: nil, userInfo: nil)
    }
    
    @objc func secondaryUserUpdatedHandler() {
        updateValues()
    }
    
    private func updateValues() {
        DispatchQueue.main.async {
            let secondaryUser = SecondaryUserSession.GetUser()
            self.userNameLabel.stringValue = (secondaryUser?.userName ?? "") + " - " + (secondaryUser?.role.rawValue ?? "")
            self.setupTimer()
        }
    }
    
    private func setupTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        let secondaryUser = SecondaryUserSession.GetUser()
        let dateDouble = (secondaryUser?.tokenExpiration)
        let date = dateDouble?.toDate1970
        let seconds = Date().segundosTranscurridos(fecha: date ?? Date())
        if seconds ?? 0 <= 0 {
            timer.invalidate()
            SecondaryUserSession.Remove()
            NotificationCenter.default.post(name: .needSecondaryUserLogin, object: nil, userInfo: nil)
        }
        let secondsString = String(seconds ?? 0)
        self.expirationToken.stringValue = "exp: \(secondsString)"
    }
}
