//
//  ProductSellView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 24/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

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
        let body = encodeSell(newRegister)
        let token = UserSaved.GetToken()
        let endpoint = BLServerManager.EndpointValue(to: .Sell(.Save(body: body, token: token)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<ArticleModel.Response>) in
            guard let _id = response.data?._id else {
                return
            }
            self.addNullPayment(sellId: _id)
        } fail: { (error) in
            print("no se pudo guardar venta de articulo", error.rawValue)
        }
        updateStock()
    }
   
    private func updateStock() {
        let path = "\(Paths.productArticle):\(selectedItem?._id ?? "")"
        let uid = UserSaved.GetUser()?.uid
        let endpoint = BLServerManager.EndpointValue(to: .Transaction(uid: uid!,
                                                                      path: path,
                                                                      key: "stock",
                                                                      value: -1))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: Bool) in
            print("stock updated", response)
        } fail: { (error) in
            print("could not update stock", error.rawValue)
        }
    }
    
    private func addNullPayment(sellId: String) {
        let createdAt = Date().timeIntervalSince1970
        let customerId : String = selectedCustomer._id

        let newRegister = PaymentModel.Response(customer: customerId,
                                                sell: sellId,
                                                isEnabled: true,
                                                timestamp: createdAt,
                                                paidAmount: 0,
                                                productCategory: ProductCategory.article.rawValue)
        
        let token = UserSaved.GetToken()
        let body = encodePayment(newRegister)
        let endpoint = BLServerManager.EndpointValue(to: .Payment(.Save(body: body, token: token)))
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<PaymentModel.Response>) in
            self.buttonAccept.hideLoading()
            DispatchQueue.main.async {
                self.hideView()
                NotificationCenter.default.post(name: .needUpdateCustomerList, object: nil)
                NotificationCenter.default.post(.init(name: .needUpdateArticleList))
            }
        } fail: { (error) in
            print("No se puedo guardar pago nulo")
            self.buttonAccept.hideLoading()
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

}
