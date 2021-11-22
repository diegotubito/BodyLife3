//
//  BaseViewController.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

enum AlertButton: String, CaseIterable {
    case ok = "OK"
    case delete = "Borrar"
    case cancel = "Cancelar"
}

class BaseViewController : NSViewController {
    var AlertSheet : NSAlert!
    var lockBackgroundView : NSView!
    var noConnectionView : ErrorMessageView!
    var proportional : Proportion = Proportion()
 
    override func viewDidLoad() {
        super .viewDidLoad()
        DDBarLoader.color = Constants.Colors.Blue.saturatedBlue
        DDBarLoader.roundedCap = true
        listenToNotification()
    }
    
    struct Proportion {
        var width : CGFloat!
        var height : CGFloat!
    }
    
    func setupWindow(width: CGFloat, height: CGFloat) {
        proportional.width = width
        proportional.height = height
        adjustWindowSize()
        
        view.window?.contentView?.wantsLayer = true
        view.wantsLayer = true
        view.window?.isOpaque = false
        //    view.window?.hasShadow = false
        view.window?.backgroundColor = NSColor.black
        // view.window?.titlebarAppearsTransparent = true
    }
    
    private func adjustWindowSize() {
//        let (screenWidth, screenHeight) = getScreenSize()
//        let windowWidth : CGFloat = screenWidth * proportional.width
//        let windowHeight : CGFloat = screenHeight * proportional.height
//
//        let newRect = NSRect(x: screenWidth/2 - windowWidth/2, y: screenHeight/2 - windowHeight/2, width: windowWidth, height: windowHeight)
//        let newSize = NSSize(width: windowWidth, height: windowHeight)
//
//        view.setFrameSize(newSize)
//        view.window?.setFrame(newRect, display: false)
    }
    
    func getScreenSize() -> (CGFloat, CGFloat){
        if let screen = NSScreen.main {
            let rect = screen.frame
            let height = rect.size.height
            let width = rect.size.width
            
            return (width, height)
        }
        return (0, 0)
    }
    
    func listenToNotification() {
           
        NotificationCenter.default.addObserver(self, selector: #selector(disconnected(notification:)), name: .ServerDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connected), name: .ServerConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GoToLogin), name: .NeedLogin, object: nil)
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    @objc func connected() {
        if noConnectionView != nil {
            self.unlockBackground()
            self.deleteNoConnectionView()
        }
    }
    
    @objc func disconnected(notification: Notification) {
        DispatchQueue.main.async {
            let message = notification.object as? String
            self.unlockBackground()
            self.deleteNoConnectionView()
            self.showNoConnection(message: message ?? "Error Desconocido")
            
        }
    }
    
    func showNoConnection(message: String) {
        
        lockBackground()
        
        noConnectionView = ErrorMessageView(frame: CGRect.zero)
        noConnectionView.title = message
        view.addSubview(noConnectionView)
       
        noConnectionView.translatesAutoresizingMaskIntoConstraints = false
        let c1 = NSLayoutConstraint(item: noConnectionView!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let c2 = NSLayoutConstraint(item: noConnectionView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let c3 = NSLayoutConstraint(item: noConnectionView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350)
        let c4 = NSLayoutConstraint(item: noConnectionView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 230)
        
        view.addConstraints([c1, c2, c3, c4])
    }
   
    func lockBackground() {
        let (screenWidth, screenHeight) = getScreenSize()
       
        let backgroundView = NSView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroundView.wantsLayer = true
         
        backgroundView.Blur()
        
        
        lockBackgroundView = backgroundView
        view.addSubview(lockBackgroundView)
        
        let click = NSClickGestureRecognizer(target: self, action: #selector(backgroundTouched))
        lockBackgroundView.addGestureRecognizer(click)
        
    }
    
    @objc func backgroundTouched() {
       //make this view touchable, if not, background object are available.
    }
  
    @objc func foregroundTouched() {
        //make this view touchable, if not, background object are available.
    }
    
    func unlockBackground() {
        if lockBackgroundView != nil {
            lockBackgroundView.removeFromSuperview()
        }
    }
    
    func deleteNoConnectionView() {
        if noConnectionView == nil {return}
        noConnectionView.removeFromSuperview()
        noConnectionView = nil
    }
      
    func showLoading() {
        DDBarLoader.showLoading(controller: self, message: "Loading")
    }
    
    func hideLoading() {
        DDBarLoader.hideLoading()
    }
    
       
    func routeToLogin(sameUserName: Bool, didLogin: @escaping (Data)->())
    {
        let storyboard = NSStoryboard(name: "LoginStoryboard", bundle: nil)
         
        let destinationVC = storyboard.instantiateController(withIdentifier: "LoginViewController") as! LoginViewController
    
        destinationVC.sameUserName = sameUserName
        destinationVC.didLogin = { data in
            didLogin(data)
        }
        DispatchQueue.main.async {
            self.presentAsSheet(destinationVC)
        }
    }
    
    @objc func GoToLogin() {
        DispatchQueue.main.async {
            var sameUserName = false
            if (MainUserSession.GetUser()?.uid) != nil {
                sameUserName = true
            }
            self.routeToLogin(sameUserName: sameUserName) { data in
                MainUserSession.Save(userData: data)
            }
        }
    }
    
    func ShowSheetAlert(title: String, message: String, buttons: [AlertButton]) {
        DispatchQueue.main.async {
            self.AlertSheet = NSAlert()
            self.AlertSheet.messageText = title
            self.AlertSheet.informativeText = message
            
            buttons.forEach { button in
                self.AlertSheet.addButton(withTitle: button.rawValue)
            }
            
            self.AlertSheet.alertStyle = .informational
            
            self.AlertSheet.beginSheetModal(for: self.view.window!) { result in
                switch result {
                case NSApplication.ModalResponse.alertFirstButtonReturn:
                    self.alertFirstButton()
                    break
                case NSApplication.ModalResponse.alertSecondButtonReturn:
                    self.alertSecondButton()
                    break
                case NSApplication.ModalResponse.alertThirdButtonReturn:
                    self.alertThirdButton()
                    break
                default:
                    print("There is no provision for further buttons")
                }
            }
            
            
        }
        
    }
    
    @objc func alertFirstButton() {
    }
    
    @objc func alertSecondButton() {
    }
    
    @objc func alertThirdButton() {
    }
    
    func notificationMessage(messageID: String, title: String, subtitle: String, informativeText: String) {
        // Create the notification and setup information
        let notification = NSUserNotification()
        notification.identifier = messageID
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = informativeText
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.contentImage = #imageLiteral(resourceName: "logo_body_life")
        // Manually display the notification
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
    }
}
