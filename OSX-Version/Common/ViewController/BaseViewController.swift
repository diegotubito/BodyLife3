//
//  BaseViewController.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

class BaseViewController : NSViewController {
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
    
    func adjustWindowSize() {
        let (screenWidth, screenHeight) = getScreenSize()
        let windowWidth : CGFloat = screenWidth * proportional.width
        let windowHeight : CGFloat = screenHeight * proportional.height
        
        let newRect = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        let newSize = NSSize(width: windowWidth, height: windowHeight)
        
        view.setFrameSize(newSize)
        view.window?.setFrame(newRect, display: true)
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
        NotificationCenter.default.addObserver(self, selector: #selector(reachable), name: Notification.Name.Reachability.reachable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nonReachable), name: Notification.Name.Reachability.notReachable, object: nil)
    }
    
    @objc func reachable() {
        if noConnectionView != nil {
            self.unlockBackground()
            self.deleteErrorView()
        }
    }
    
    @objc func nonReachable() {
        showNoConnection(message: "Ups parece que estamos sin conexión.")
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
         
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(5.0, forKey: kCIInputRadiusKey)
        backgroundView.layer?.backgroundFilters?.append(blurFilter!)
        
        
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
    
    func deleteErrorView() {
        if noConnectionView != nil {
            noConnectionView.removeFromSuperview()
        }
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
    
    func CheckLogin() {
        var needLogin = false
        let semasphore = DispatchSemaphore(value: 0)
        
        ServerManager.CurrentUser { (currentUser, serverError) in
            
            if serverError != nil {
                if serverError! == ServerError.invalidToken || serverError == ServerError.tokenNotProvided {
                    if serverError! == ServerError.invalidToken {
                        print("token vencido: ", UserSaved.TokenExp()?.toString(formato: "dd-MM-yyyy HH:mm:ss") ?? "nil")
                    }
                    print("need new login:", ErrorHandler.Server(error: serverError!))
                    needLogin = true
                }
            } else {
                UserSaved.SaveDate(date: currentUser?.exp)
                print("token vigente: ", UserSaved.TokenExp()?.toString(formato: "dd-MM-yyyy HH:mm:ss") ?? "nil")
                
            }
            semasphore.signal()
        }
        
        _ = semasphore.wait(timeout: .distantFuture)
        
        if needLogin {
            print("go to login")
            GoToLogin(sameUserName: false)
        }
        
    }
    
    @objc func GoToLogin(sameUserName: Bool) {
        DispatchQueue.main.async {
            self.routeToLogin(sameUserName: sameUserName) { data in
                print("successfull")
                UserSaved.Save(userData: data)
                
            }
            
        }
    }
}
