//
//  ProductSellView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 24/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class ArticleSellView: XibViewBlurBackground {
    var productListView : ArticleListView!
    var buttonAccept : SaveButtonCustomView!
    var selectedCustomer : CustomerModel!
    var myActivityIndicator : NSProgressIndicator!
     
    var selectedItem : ArticleModel? {
        didSet {
            buttonAccept.isEnabled = selectedItem != nil ? true : false
        }
    }
    
    override func commonInit() {
        super .commonInit()
       
        createBackgroundGradient()

        createProductListView()
        addAcceptButton()
        addObservers()
        
    }
    
    
    func createBackgroundGradient() {
        self.layer?.backgroundColor = NSColor.black.cgColor
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5, 1]
        gradient.colors = [NSColor(hex: 0x020707).cgColor,
                           NSColor(hex: 0x1A3B78).withAlphaComponent(0.7).cgColor,
                           NSColor(hex: 0x020707).cgColor]
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.layer?.addSublayer(gradient)
    }
    
    func addAcceptButton() {
        let ancho : CGFloat = 100
        let alto : CGFloat = 40
        
        buttonAccept = SaveButtonCustomView(frame: CGRect(x: self.frame.width/2 - ancho/2, y: 8, width: ancho, height: alto))
        buttonAccept.title = "Guardar"
        self.addSubview(buttonAccept)
        buttonAccept.isEnabled = false
    }
    
    func addObservers() {
        productListView.onSelectedItem = {item in
            self.selectedItem = item
        }
        
        buttonAccept.onButtonPressed = {
            DispatchQueue.main.async {
                self.save()
            }
        }
    }
    
    func createProductListView() {
        let alto = self.frame.height * 0.8
        productListView = ArticleListView(frame: CGRect(x: 16, y: self.frame.height - alto - 16, width: self.frame.width - 32, height: alto))
        productListView.collectionView.layer?.backgroundColor = NSColor.clear.cgColor
        self.addSubview(productListView)
    }
    
    override func showView() {
        super .showView()
        productListView.collectionView.deselectAll(nil)
        selectedItem = nil
        productListView.scrollView.becomeFirstResponder()
        productListView.collectionView.reloadData()
    }
    
    func save() {
        self.buttonAccept.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 0)) {
            self.saveNewSell { (success) in
                self.hideView()
                self.buttonAccept.hideLoading()
                if success {
                    NotificationCenter.default.post(name: .needUpdateCustomerList, object: nil)
                    NotificationCenter.default.post(.init(name: .needUpdateArticleList))
                }
            }
        }
        
    }
    
    func saveNewSell(completion: (Bool) -> ()) {
        var error : ServerError?
        let semasphore = DispatchSemaphore(value: 0)
        let request = createRequest()
        
        let pathArticleSellCount = "\(Paths.productArticle):\((selectedItem?.childID)!)"
        ServerManager.Transaction(path: pathArticleSellCount, key: "sellCount", value: 1, success: {
        }) { (err) in
            error = err
        }
        
        let pathArticleStock = "\(Paths.productArticle):\((selectedItem?.childID)!)"
        ServerManager.Transaction(path: pathArticleStock, key: "stock", value: -1, success: {
        }) { (err) in
            error = err
        }
        
        let path = Paths.registers
        ServerManager.Update(path: path, json: request) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathStatusSell = "\(Paths.fullPersonalData):\(selectedCustomer.childID):sells"
        ServerManager.Update(path: pathStatusSell, json: request) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathStatus = "\(Paths.customerStatus):\(selectedCustomer.childID)"
        ServerManager.Transaction(path: pathStatus, key: "balance", value: -(selectedItem?.price)!, success: {
            semasphore.signal()
        }) { (err) in
            error = err
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        self.buttonAccept.hideLoading()
        completion(true)
        
        
    }
    
    func createRequest() -> [String: Any] {
        var json = [String : Any]()
        let childID = ServerManager.createNewChildID()
        json.updateValue(childID, forKey: "childID")
        json.updateValue(selectedCustomer.childID, forKey: "childIDCustomer")
        json.updateValue((selectedItem?.childID)!, forKey: "childIDArticle")
        json.updateValue(Date().timeIntervalSinceReferenceDate, forKey: "createdAt")
        json.updateValue(Date().queryByDMY, forKey: "queryByDMY")
        json.updateValue(Date().queryByMY, forKey: "queryByMY")
        json.updateValue(Date().queryByY, forKey: "queryByY")
        json.updateValue(RegisterType.income, forKey: "registerType")
        json.updateValue(true, forKey: "isEnabled")
        json.updateValue((selectedItem?.price)!, forKey: "amount")
        json.updateValue(0, forKey: "amountDiscounted")
        json.updateValue((selectedItem?.price)!, forKey: "amountToPay")
        json.updateValue((selectedItem?.name)!, forKey: "displayName")
        
        let result = [childID : json]
        return result
    }
    
    
}
