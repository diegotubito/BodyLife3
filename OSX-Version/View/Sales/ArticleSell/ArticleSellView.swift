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
    var selectedCustomer : CustomerModel.Customer!
    var myActivityIndicator : NSProgressIndicator!
     
    var selectedItem : ArticleModel.NewRegister? {
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
        let alto = self.frame.height * 0.7
        productListView = ArticleListView(frame: CGRect(x: 16, y: self.frame.height - alto - 32, width: self.frame.width - 32, height: alto))
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
        
        let createdAt = Date().timeIntervalSince1970
        let customerId = ImportDatabase.codeUID((selectedCustomer.uid))
        let dicountID : String? = nil
        let article = selectedItem?._id

        let newRegister = SellModel.NewRegister(customer: customerId,
                                                discount: dicountID,
                                                activity: nil,
                                                article: article,
                                                period: nil,
                                                timestamp: createdAt,
                                                fromDate: nil,
                                                toDate: nil,
                                                quantity: 1,
                                                isEnabled: true,
                                                productCategory: ProductCategory.article.rawValue,
                                                price: selectedItem?.price,
                                                priceList: selectedItem?.price,
                                                priceCost: selectedItem?.priceCost,
                                                description: selectedItem?.description ?? "")
        
        let url = "http://127.0.0.1:2999/v1/sell"
        let _services = NetwordManager()
        let body = encodeSell(newRegister)
        _services.post(url: url, body: body) { (data, error) in
            guard data != nil else {
                print("no se pudo guardar venta de articulo")
                return
            }
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            let _id = json?["_id"] as? String
            
            self.addNullPayment(sellId: _id!)
        }
    }
    
    private func addNullPayment(sellId: String) {
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = ImportDatabase.codeUID((selectedCustomer.uid))

        let newRegister = PaymentModel.Response(customer: customerId,
                                                sell: sellId,
                                                isEnabled: true,
                                                timestamp: createdAt,
                                                paidAmount: 0,
                                                productCategory: ProductCategory.article.rawValue)
        
        let url = "http://127.0.0.1:2999/v1/payment"
        let _services = NetwordManager()
        let body = encodePayment(newRegister)
        _services.post(url: url, body: body) { (data, error) in
            DispatchQueue.main.async {
                self.buttonAccept.hideLoading()
            }
            guard data != nil else {
                print("No se puedo guardar pago nulo")
                return
            }
            DispatchQueue.main.async {
                self.hideView()
                NotificationCenter.default.post(name: .needUpdateCustomerList, object: nil)
                NotificationCenter.default.post(.init(name: .needUpdateArticleList))
            }
        }
    }
    
    private func encodeSell(_ register: SellModel.NewRegister) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
    
    private func encodePayment(_ register: PaymentModel.Response) -> [String : Any] {
        let data = try? JSONEncoder().encode(register)
        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
        return json!
    }
    
/*    func saveNewSell(completion: (Bool) -> ()) {
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
        
        let pathStatusSell = "\(Paths.fullPersonalData):\(selectedCustomer.uid):sells"
        ServerManager.Update(path: pathStatusSell, json: request) { (data, err) in
            error = err
            semasphore.signal()
        }
        _ = semasphore.wait(timeout: .distantFuture)
        if error != nil {
            completion(false)
            return
        }
        
        let pathStatus = "\(Paths.customerStatus):\(selectedCustomer.uid)"
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
 */
}
