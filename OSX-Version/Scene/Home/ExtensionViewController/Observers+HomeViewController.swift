//
//  Observers+HomeViewController.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 16/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

extension HomeViewController {
    
    func addObservers() {
        customerListOberserver()
        buttonObserverProductSell()
        buttonObserverEditProfilePicture()
        buttonObserverActivitySell()
        buttonObserverPayment()
    }
    
    func customerListOberserver() {
        self.customerListView.onSelectedCustomer = { [weak self] customer in
            guard let customer = customer else {
                self?.customerStatusView.initValues()
                self?.sellRegisterView.viewModel.initValues()
                return
            }
            self?.selectedCustomer = customer
            self?.timerForDelayCustomerSelection.invalidate()
            self?.customerStatusView.showLoading()
            let age = customer.dob.toDate1970.age()
            self?.customerStatusView.ageLabel.stringValue = String(age) + " Años"
            self?.customerStatusView.titleLabel.stringValue = customer.lastName + ", " + customer.firstName
            self?.sellRegisterView.setSelectedCustomer(customer: customer)
            self?.timerForDelayCustomerSelection = Timer.scheduledTimer(timeInterval: 0.25, target: self as Any, selector: #selector(self?.loadStatus), userInfo: nil, repeats: false)
            if ((self?.sellRegisterView.isHidden) != nil) {
                self?.sellRegisterView.animateMode = .fadeIn
            }
            
        }
    }
    
    func buttonObserverActivitySell() {
        self.customerStatusView.didPressSellActivityButton = { [weak self] in
            //open sell activities custom view
            let selectedCustomer = self?.customerListView.viewModel.model.selectedCustomer
            let loadedStatus = self?.customerStatusView.viewModel.model.loadedStatus
//            self.sellActivityView.viewModel.setCustomerStatus(selectedCustomer: selectedCustomer!, selectedStatus: loadedStatus)
            self?.sellActivityView.showView()
        }
    }
    
    func buttonObserverProductSell() {
        self.customerStatusView.didPressSellProductButton = { [weak self] in
            self?.sellProductView.selectedCustomer = (self?.selectedCustomer)!
            self?.sellProductView.showView()
        }
    }
    
    func buttonObserverEditProfilePicture() {
        self.customerStatusView.didPressEditProfilePicture = { [weak self] in
            //route to camera virecontroller
            let storyboard = NSStoryboard(name: "NewCustomerStoryboard", bundle: nil)
            
            let destinationVC = storyboard.instantiateController(withIdentifier: "CameraViewController") as! CameraViewController
            destinationVC.delegate = self
            self?.presentAsSheet(destinationVC)
        }
        
        self.customerStatusView.didPressEditProfile = { [weak self] in
            //route to camera virecontroller
            let storyboard = NSStoryboard(name: "NewCustomerStoryboard", bundle: nil)
            
            let destinationVC = storyboard.instantiateController(withIdentifier: "NewCustomerViewController") as! NewCustomerViewController
            destinationVC.customer = self?.customerStatusView.viewModel.model.receivedCustomer
            destinationVC.customerReceived = self?.customerStatusView.viewModel.model.receivedCustomer
            let image = self?.customerStatusView.downloadedImage
            destinationVC.imageToStorage = image
            destinationVC.thumbImageBase64 = image?.convertToBase64
            DispatchQueue.main.async {
                if image == nil {
                    destinationVC.CustomerIconImageView.image = #imageLiteral(resourceName: "empty")
                } else {
                    destinationVC.CustomerIconImageView.image = destinationVC.imageToStorage
                }
            }
            self?.presentAsSheet(destinationVC)
        }
        
    }
    
    func buttonObserverPayment() {
        self.sellRegisterView.onAddPayment = { payments in
            self.paymentView.viewmodel.setSelectedInfo(self.selectedCustomer!, self.sellRegisterView.viewModel.getSelectedRegister()!, payments: payments)
            self.paymentView.showView()
        }
    }
    
    func showStatusCustomer() { 
        if self.customerStatusView.isHidden {
            self.customerStatusView.animateMode = .fadeIn
        }
    }
    
    func hideStatusCustomer() {
        if self.customerStatusView.isHidden {
            self.customerStatusView.animateMode = .fadeIn
        }
    }
    
    func didSelectCustomer(customerSelected: CustomerModel.Customer?) {
        DispatchQueue.main.async {
            self.showStatusCustomer()
            self.customerStatusView.viewModel = CustomerStatusViewModel(withView: self.customerStatusView, receivedCustomer: customerSelected)
            self.sellRegisterView.viewModel.loadPayments()
        }
    }
}

extension HomeViewController: CameraViewControllerDelegate {
    func capturedImage(originalSize image: NSImage) {
        guard let customer = customerStatusView.viewModel.model.receivedCustomer else {
            return
        }
        let id = customer._id
        
        CommonWorker.Image.updateThumbnail(_id: id!, image: image) { (stringImage) in
            if stringImage != nil {
                self.customerListView.viewModel.setImageForCustomer(_id: id!, thumbnail: stringImage!)
            }
        }
        
        self.customerStatusView.showLoading()
        
        let medium = image.crop(size: NSSize(width: ImageSize.storageSize, height: ImageSize.storageSize))
        print("medium image: \(String(describing: medium?.sizeInBytes))")
      
        CommonWorker.Image.uploadImage(uid: id!, image: medium!) { (success) in
            success ? print("storage image uploaded") : print("storage image fail")
            self.customerStatusView.downloadProfileImage()
        }
    }
    
    
}
