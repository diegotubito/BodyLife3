//
//  CustomerDetailView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 19/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

extension Notification.Name {
    static let notificationUpdateStatus = Notification.Name("notificationUpdateStatus")
}


class CustomerStatusView: XibViewWithAnimation {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var ageLabel: NSTextField!
 
    @IBOutlet weak var profilePicture : NSImageView!
    @IBOutlet weak var expirationDateLabel: NSTextField!
    @IBOutlet weak var saldoLabel: NSTextField!
    @IBOutlet weak var remainingDayLabel: NSTextField!
    @IBOutlet var myView: NSView!
    @IBOutlet weak var innerBackground: NSView!
    @IBOutlet weak var line: NSView!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    @IBOutlet weak var errorView: NSView!
    var viewModel : CustomerStatusViewModelContract!
    @IBOutlet weak var DayBox: NSBox!
    @IBOutlet weak var sellArticleButtonOutlet: NSButton!
    
    @IBOutlet weak var sellActivityButtonOutlet: NSButton!
    var didPressSellActivityButton : (() -> ())?
    var didPressSellProductButton : (() -> ())?
    var profilePictureRequest : URLSessionDataTask?
    
    override func commonInit() {
        super .commonInit()
        self.wantsLayer = true
        self.layer?.borderWidth = Constants.Borders.Status.width
        self.layer?.borderColor = Constants.Borders.Status.color
        //self.layer?.backgroundColor = Constants.Colors.Gray.gray10.cgColor
        
       
        
        
        innerBackground.wantsLayer = true
        innerBackground.layer?.backgroundColor = Constants.Colors.Blue.chambray.withAlphaComponent(0.15).cgColor
        innerBackground.layer?.borderColor = NSColor.black.cgColor
        innerBackground.layer?.borderWidth = 2
        
        line.wantsLayer = true
        line.layer?.backgroundColor = Constants.Colors.Gray.gray17.cgColor
        
        errorView.wantsLayer = true
        errorView.layer?.backgroundColor = NSColor.clear.cgColor
        errorView.isHidden = true
        errorView.layer?.zPosition = 100
        
        self.DayBox.wantsLayer = true
      
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataFromNotification), name: .notificationUpdateStatus, object: nil)
    }
    
    @objc func updateDataFromNotification(notification: Notification) {
        
        let userInfo = notification.object as? CustomerStatusModel.StatusInfo
        DispatchQueue.main.async {
            self.showData(statusInfo: userInfo)
        }
       
        downloadImage(childID: viewModel.model.receivedCustomer.uid) { (image, error) in
            DispatchQueue.main.async {
                self.hideLoading()
                self.profilePicture.layer?.cornerRadius = (self.profilePicture.layer?.frame.width)! / 2
                if image != nil {
                    self.profilePicture.image = image!
                } else {
                    self.profilePicture.image = #imageLiteral(resourceName: "empty")
                }
            }
        } cancel: {
            print("cancel request")
        }
    }
    
    func initValues() {
        sellActivityButtonOutlet.isEnabled = false
        sellArticleButtonOutlet.isEnabled = false
        expirationDateLabel.stringValue = ""
        saldoLabel.stringValue = ""
        remainingDayLabel.stringValue = ""
    }
    
    func configureBoxDay() {
        self.DayBox.layer?.cornerRadius = self.DayBox.frame.height / 2
        self.DayBox.layer?.borderWidth = 1
        self.DayBox.layer?.borderColor = NSColor.darkGray.cgColor
        
    }
   
    func downloadImage(childID: String, completion: @escaping (NSImage?, Error?) -> (), cancel: () -> ()) {
//        let url = "\(Config.baseUrl.rawValue)/v1/downloadImage?filename=socios/\(childID).jpeg"
        let uid = UserSession?.uid ?? ""
        let url = "\(BLServerManager.baseUrl.rawValue)/v1/downloadImage?filename=\(uid)/customer/\(childID).jpeg"
        let _services = NetwordManager()

        if profilePictureRequest != nil {
            profilePictureRequest?.cancel()
            profilePictureRequest = nil
            cancel()
        }
        profilePictureRequest = _services.downloadImageFromUrl(url: url) { (image) in
            self.profilePictureRequest = nil
            guard let image = image else {
                completion(nil, nil)
                return
            }
            let medium = image.crop(size: NSSize(width: 200, height: 200))
            
            completion(medium, nil)
        } fail: { (err) in
            self.profilePictureRequest = nil
            completion(nil, err)
        }

    }
    @IBAction func SellActivityPressed(_ sender: Any) {
        didPressSellActivityButton?()
    }
    @IBAction func SellProductPressed(_ sender: Any) {
        didPressSellProductButton?()
    }
}


extension CustomerStatusView : CustomerStatusViewContract{
    func showData(statusInfo: CustomerStatusModel.StatusInfo?) {
        errorView.isHidden = true
        self.sellArticleButtonOutlet.isEnabled = true
        self.sellActivityButtonOutlet.isEnabled = true

        guard let statusInfo = statusInfo else {
            expirationDateLabel.stringValue = "?"
            saldoLabel.stringValue = "?"
            remainingDayLabel.stringValue = "?"
            return
        }
        let expiration = statusInfo.expiration.toString(formato: "dd-MM-yyyy")
        let balance = statusInfo.balance.currencyFormat(decimal: 2)
        
        let diff = Date().diasTranscurridos(fecha: statusInfo.expiration)
        expirationDateLabel.stringValue = expiration
        remainingDayLabel.stringValue = String(diff!)
        saldoLabel.stringValue = balance
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.errorView.isHidden = false
            self.errorView.Blur()
        }
    }
    
    func reloadList() {
        
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.initValues()
            self.activityIndicator.startAnimation(nil)
            self.profilePicture.image = nil
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimation(nil)
        }
        
    }
    
    
}
