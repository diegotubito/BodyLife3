//
//  AcitvitySaleView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 26/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let needUpdateCustomerList = Notification.Name("needUpdateCustomerList")
    static let needUpdateProductService = Notification.Name("needUpdateProductService")
}

class ActivitySaleView : XibViewBlurBackground {
    @IBOutlet weak var myIndicator: NSProgressIndicator!
    @IBOutlet weak var saveButtonView: SaveButtonCustomView!
    @IBOutlet weak var expirationLabel: NSTextField!
    @IBOutlet weak var daysLabel: NSTextField!
    @IBOutlet weak var priceLabel: NSTextField!
    @IBOutlet weak var discountLabel: NSTextField!
    @IBOutlet weak var totalLabel: NSTextField!
    @IBOutlet weak var periodViewContainer: NSView!
    var periodListView : PeriodListView!
    @IBOutlet weak var popupActivity: NSPopUpButton!
    
    @IBOutlet weak var popupDiscount: NSPopUpButton!
    @IBOutlet weak var backgroundClickableView: NSView!
    var viewModel : ActivitySaleViewModelContract!
    
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var endDate: NSDatePicker!
    override func commonInit() {
        super .commonInit()
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadDataHandler), name: .needUpdateProductService, object: nil)
        
        disableDates()
        viewModel = ActivitySaleViewModel(withView: self)
        createProductListView()
        viewModel.loadPeriods()
        viewModel.loadDiscounts()
        
        addObserver()
        
        createBackgroundGradient()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDataFromNotification), name: .notificationUpdateStatus, object: nil)
    }
    
    @objc func updateDataFromNotification(notification: Notification) {
        let userInfo = notification.object as? CustomerStatusModel.StatusInfo
        viewModel.setStatusInfo(userInfo)
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
    
    private func addObserver() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(backTouched))
        backgroundClickableView.addGestureRecognizer(clickGesture)
        
        periodListView.didSelectPeriod = { period in
            self.viewModel.setSelectedPeriod(period)
            self.viewModel.setEndDate()
            self.updateValues()
        }
        buttonSaveObserver()
    }
    
    func buttonSaveObserver() {
        saveButtonView.onButtonPressed = {
            if self.viewModel.validate() {
                let (price, discount) = self.viewModel.getTotals()
                self.viewModel.save(fromDate: self.fromDate.dateValue,
                                    toDate: self.endDate.dateValue,
                                    price: (price - discount),
                                    priceList: price)
            }
        }
    }
    
    @objc func loadDataHandler() {
        viewModel.loadPeriods()
    }
    
    @objc private func backTouched() {
        print("touched")
    }
    
    func createProductListView() {
      
        periodListView = PeriodListView(frame: CGRect(x: 0, y: 0, width: periodViewContainer.frame.width, height: periodViewContainer.frame.height))
        periodListView.collectionView.layer?.backgroundColor = NSColor.clear.cgColor
        periodViewContainer.addSubview(periodListView)
        periodViewContainer.layer?.backgroundColor = NSColor.red.cgColor
    }
    @IBAction func typePopupDidChanged(_ sender: NSPopUpButton) {
        viewModel.selectActivity(sender.indexOfSelectedItem)
        viewModel.setSelectedPeriod(nil)
        viewModel.setEndDate()
        showPeriods()
        updateValues()
    }
    
    @IBAction func discountPopupDidChanged(_ sender: NSPopUpButton) {
        viewModel.selectDiscount(sender.indexOfSelectedItem - 1) // first item is not coming from api
        updateValues()
    }
    
    
    @IBAction func fromDateDidChanged(_ sender: NSDatePicker?) {
        viewModel.setFromDate(value: fromDate.dateValue)
    }
    
    @IBAction func endDateDidChanged(_ sender: NSDatePicker) {
        
    }
    
    override func showView() {
        super .showView()
      
    }
    
    private func showActivitiesPopup() {
        let types = viewModel.getActivities()
        let titles = types.map { (type) -> String in
            return type.description
        }
        popupActivity.addItems(withTitles: titles)
    }
    
    private func showDiscountsPopup() {
        let discounts = viewModel.getDiscounts()
        var titles = discounts.map { (discount) -> String in
            return discount.description
        }
        titles.insert("Sin Descuento", at: 0)
        popupDiscount.addItems(withTitles: titles)
    }
    
    private func disableDates() {
        fromDate.isEnabled = false
        endDate.isEnabled = false
    }
    
    private func enableDates() {
        fromDate.isEnabled = true
    }
    
    private func updateValues() {
        DispatchQueue.main.async {
            self.updateRithtView()
        }
    }
    
    private func updateRithtView() {
        expirationLabel.stringValue = endDate.dateValue.toString(formato: "dd-MM-yyyy")
        let days = endDate.dateValue.diasTranscurridos(fecha: Date()) ?? 0
        daysLabel.stringValue = String(-days + 1)
        
        let (price, discount) = viewModel.getTotals()
        priceLabel.stringValue = price.currencyFormat(decimal: 2)
        discountLabel.stringValue = discount.currencyFormat(decimal: 2)
        totalLabel.stringValue = (price - discount).currencyFormat(decimal: 2)
        viewModel.validate() ? enableSaveButton() : disableSaveButton()
    }
    
    private func enableSaveButton() {
        saveButtonView.isEnabled = true
    }
    
    private func disableSaveButton() {
        saveButtonView.isEnabled = false
    }
}


extension ActivitySaleView: ActivitySaleViewContract {
   
    func showSuccessSaving() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .needUpdateCustomerList, object: nil)
            self.hideView()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            print(message)
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.myIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.myIndicator.stopAnimation(nil)
        }
    }
    
    func showActivities() {
        DispatchQueue.main.async {
            self.showActivitiesPopup()
        }
    }
    
    func showDiscounts() {
        DispatchQueue.main.async {
            self.showDiscountsPopup()
        }
    }
    
    func showPeriods() {
        self.viewModel.setSelectedPeriod(nil)
        self.periodListView.items = self.viewModel.getPeriods()
        
        DispatchQueue.main.async {
            self.periodListView.displayList()
            self.updateValues()
        }
    }
    
    func setPopupActivitydByTitle(_ value: String?) {
        DispatchQueue.main.async {
            self.popupActivity.selectItem(withTitle: value ?? "")
            self.showPeriods()
        }
    }
    
    func setPopupDiscountByTitle(_ value: String?) {
        DispatchQueue.main.async {
            self.popupDiscount.selectItem(withTitle: value ?? "")
        }
    }
    
    func showFromDate(value: Date) {
        enableDates()
        fromDate.dateValue = value
    }
    
    func showEndDate(value: Date) {
        enableDates()
        endDate.dateValue = value
        updateValues()
    }
}

extension ActivitySaleView: XibViewblurBackgroundDelegate {
    func viewWillShow() {
        resetValues()

    }
    
    func viewWillHide() {
        
    }
    
    func resetValues() {
        setPopupActivitydByTitle(nil)
        viewModel.setSelectedPeriod(nil)
        viewModel.setSelectedActivity(nil)
        periodListView.items.removeAll()
        periodListView.collectionView.reloadData()
        viewModel.setFromDate()
        viewModel.setEndDate()
        viewModel.selectDiscountAutomatically()
        viewModel.selectActivityAutomatically()
    }
    
}
