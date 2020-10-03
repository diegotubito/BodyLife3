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
    @IBOutlet weak var popupType: NSPopUpButton!
    
    @IBOutlet weak var popupDiscount: NSPopUpButton!
    @IBOutlet weak var backgroundClickableView: NSView!
    var viewModel : ActivitySaleViewModelContract!
    
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var endDate: NSDatePicker!
    override func commonInit() {
        super .commonInit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadDataHandler), name: .needUpdateProductService, object: nil)
        
        disableDates()
        viewModel = ActivitySaleViewModel(withView: self)
        createProductListView()
        viewModel.loadPeriods()
        viewModel.loadDiscounts()
        
        addObserver()
        
        createBackgroundGradient()
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
            self.updateTotal()
        }
        buttonSaveObserver()
    }
    
    func buttonSaveObserver() {
        saveButtonView.onButtonPressed = {
            if self.viewModel.validate() {
//                self.viewModel.save()
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
        updateTotal()
    }
    
    @IBAction func discountPopupDidChanged(_ sender: NSPopUpButton) {
        viewModel.selectDiscount(sender.indexOfSelectedItem - 1) // first item is not coming from api
        updateTotal()
    }
    
    
    @IBAction func fromDateDidChanged(_ sender: NSDatePicker) {
        let selectedPeriod = viewModel.getSelectedPeriod()
        
        let days = selectedPeriod?.days ?? 0
        
        let properDate = viewModel.getProperFromDate()
        let diff = properDate.diasTranscurridos(fecha: Date()) ?? 0
        let intervaloPermitidoDeDias = fromDate.dateValue.diasTranscurridos(fecha: Date()) ?? 0
        if diff > 0 || intervaloPermitidoDeDias < -10 || intervaloPermitidoDeDias > 30 {
            fromDate.dateValue = viewModel.getProperFromDate()
            return
        }
     
        endDate.dateValue = fromDate.dateValue
        endDate.dateValue.addDays(valor: days)
    }
    
    @IBAction func endDateDidChanged(_ sender: NSDatePicker) {
        
    }
    
    override func showView() {
        super .showView()
        viewModel.selectTypeAutomatically()
        viewModel.selectDiscountAutomatically()
        updateTotal()
    }
    
    private func showActivitiesPopup() {
        let types = viewModel.getActivities()
        let titles = types.map { (type) -> String in
            return type.description
        }
        popupType.addItems(withTitles: titles)
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
    
    private func updateTotal() {
        expirationLabel.stringValue = viewModel.getExpirationDate()
        daysLabel.stringValue = viewModel.getRemainingDays()
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
            
        }
    }
    
    func getToDate() -> Date {
        return endDate.dateValue
    }
    
    func getFromDate() -> Date {
        return fromDate.dateValue
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
            self.periodListView.collectionView.deselectAll(nil)
        }
    }
    
    func setPopupPeriodByTitle(_ value: String?) {
        popupType.selectItem(withTitle: value ?? "")
    }
    
    func setPopupDiscountByTitle(_ value: String?) {
        popupDiscount.selectItem(withTitle: value ?? "")
    }
    
    func adjustDates() {
        DispatchQueue.main.async {
            let selectedPeriod = self.viewModel.getSelectedPeriod()
            
            if selectedPeriod == nil {
                self.fromDate.dateValue = self.viewModel.getProperFromDate()
                self.endDate.dateValue = self.viewModel.getProperFromDate()
                self.disableDates()
                return
            }
            self.enableDates()
            let days = selectedPeriod?.days ?? 0
            self.fromDate.dateValue = self.viewModel.getProperFromDate()
            self.endDate.dateValue = self.fromDate.dateValue
            self.endDate.dateValue.addDays(valor: days)

        }
    }
    
}
