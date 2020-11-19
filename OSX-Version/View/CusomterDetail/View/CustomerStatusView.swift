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
    
    @IBOutlet weak var editProfilePictureOutlet: NSButton!
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
    var didPressEditProfilePicture : (() -> ())?
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
       
        downloadProfileImage()
    }
    
    func downloadProfileImage() {
        guard let customer = viewModel.model.receivedCustomer else {
            return
        }
        downloadImage(childID: customer._id) { (image, error) in
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
        editProfilePictureOutlet.isEnabled = false
        sellActivityButtonOutlet.isEnabled = false
        sellArticleButtonOutlet.isEnabled = false
        expirationDateLabel.stringValue = ""
        saldoLabel.stringValue = ""
        remainingDayLabel.stringValue = ""
        profilePicture.image = nil
        titleLabel.stringValue = ""
        ageLabel.stringValue = ""
    }
    
    func configureBoxDay() {
        self.DayBox.layer?.cornerRadius = self.DayBox.frame.height / 2
        self.DayBox.layer?.borderWidth = 1
        self.DayBox.layer?.borderColor = NSColor.darkGray.cgColor
        
    }
   
    func downloadImage(childID: String, completion: @escaping (NSImage?, Error?) -> (), cancel: () -> ()) {
        if profilePictureRequest != nil {
            profilePictureRequest?.cancel()
            profilePictureRequest = nil
            cancel()
        }
        
        let userUID = UserSaved.GetUID()
        let endpoint = Endpoint.Create(to: .Image(.LoadBigSize(userUID: userUID, customerUID: childID)))
        BLServerManager.ApiCall(endpoint: endpoint) { (data) in
            self.profilePictureRequest = nil
            guard let data = data, let image = NSImage(data: data) else {
                completion(nil, nil)
                return
            }
            let medium = image.crop(size: NSSize(width: ImageSize.storageSize, height: ImageSize.storageSize))
            
            completion(medium, nil)
        } fail: { (error) in
            self.profilePictureRequest = nil
            completion(nil, error)
        }

    }
    @IBAction func SellActivityPressed(_ sender: Any) {
        didPressSellActivityButton?()
    }
    @IBAction func SellProductPressed(_ sender: Any) {
        didPressSellProductButton?()
    }
    @IBAction func editPictureProfilePressed(_ sender: Any) {
        didPressEditProfilePicture?()
    }
}


extension CustomerStatusView : CustomerStatusViewContract{
    func showData(statusInfo: CustomerStatusModel.StatusInfo?) {
        errorView.isHidden = true
        self.sellArticleButtonOutlet.isEnabled = true
        self.sellActivityButtonOutlet.isEnabled = true
        
        guard let statusInfo = statusInfo else {
            return
        }
        let balance = statusInfo.balance.currencyFormat(decimal: 2)
        saldoLabel.stringValue = balance
        saldoLabel.textColor =  statusInfo.balance >= 0 ? NSColor.lightGray : Constants.Colors.Red.ematita

        guard statusInfo.lastActivityId != nil else {
            expirationDateLabel.stringValue = "---"
            remainingDayLabel.stringValue = "---"
            expirationDateLabel.textColor = Constants.Colors.Red.ematita
            remainingDayLabel.textColor = Constants.Colors.Red.ematita
            return
        }
       
        let expiration = statusInfo.expiration.toString(formato: "dd-MM-yyyy")
       
        
        let diff = Date().diasTranscurridos(fecha: statusInfo.expiration)
        expirationDateLabel.stringValue = expiration
        remainingDayLabel.stringValue = String(diff!)
        remainingDayLabel.textColor =  diff! >= 0 ? NSColor.lightGray : Constants.Colors.Red.ematita
        expirationDateLabel.textColor =  diff! >= 0 ? NSColor.lightGray : Constants.Colors.Red.ematita

        
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
            self.sellArticleButtonOutlet.isEnabled = false
            self.sellActivityButtonOutlet.isEnabled = false
            self.activityIndicator.startAnimation(nil)
            self.profilePicture.image = nil
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.sellArticleButtonOutlet.isEnabled = true
            self.sellActivityButtonOutlet.isEnabled = true
            self.activityIndicator.stopAnimation(nil)
            self.editProfilePictureOutlet.isEnabled = true
        }
        
    }
    
    
}
