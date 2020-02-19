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
    @IBOutlet weak var activityViewContainer: NSView!
    var activityListView : ActivityListView!
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
        viewModel.loadServices()
        
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
        
        activityListView.didSelectActivity = { activity in
            self.viewModel.setSelectedActivity(activity)
            self.updateTotal()
        }
        
        buttonSaveObserver()
        
    }
    
    func buttonSaveObserver() {
    
        saveButtonView.onButtonPressed = {
            if self.viewModel.validate() {
                self.viewModel.save()
            }
        }
    }
    
    @objc func loadDataHandler() {
        viewModel.loadServices()
    }
    
    @objc private func backTouched() {
        print("touched")
    }
    
    func createProductListView() {
        activityListView = ActivityListView(frame: CGRect(x: 0, y: 0, width: activityViewContainer.frame.width, height: activityViewContainer.frame.height))
        activityListView.collectionView.layer?.backgroundColor = NSColor.clear.cgColor
        activityViewContainer.addSubview(activityListView)
    }
    @IBAction func typePopupDidChanged(_ sender: NSPopUpButton) {
        viewModel.selectType(sender.indexOfSelectedItem)
        updateTotal()
    }
    
    @IBAction func discountPopupDidChanged(_ sender: NSPopUpButton) {
        viewModel.selectDiscount(sender.indexOfSelectedItem)
        updateTotal()
    }
    
    
    @IBAction func fromDateDidChanged(_ sender: NSDatePicker) {
        let selectedActivity = viewModel.getSelectedActivity()
        let days = selectedActivity?.days
            ?? 0
        
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
    
    private func showTypes() {
        loadTypesPopup()
    }
    
    private func showDiscounts() {
        loadDiscountsPopup()
    }
    
    private func loadTypesPopup() {
        let types = viewModel.getTypes()
        let titles = types.map { (type) -> String in
            return type.name
        }
        popupType.addItems(withTitles: titles)
    }
    
    private func loadDiscountsPopup() {
        let discounts = viewModel.getDiscounts()
        var titles = discounts.map { (discount) -> String in
            return discount.name
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
        priceLabel.stringValue = price.formatoMoneda(decimales: 2, simbolo: "$")
        discountLabel.stringValue = discount.formatoMoneda(decimales: 2, simbolo: "$")
        totalLabel.stringValue = (price - discount).formatoMoneda(decimales: 2, simbolo: "$")
        
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
    
    func showSuccess() {
        DispatchQueue.main.async {
            self.showTypes()
            self.showDiscounts()
        }
    }
    
    func showActivities() {
        self.viewModel.setSelectedActivity(nil)
        self.activityListView.items = self.viewModel.getActivities()
        
        DispatchQueue.main.async {
            self.activityListView.displayList()
            self.activityListView.collectionView.deselectAll(nil)
        }
    }
    
    func setPopupTypeByTitle(_ value: String?) {
        popupType.selectItem(withTitle: value ?? "")
    }
    
    func setPopupDiscountByTitle(_ value: String?) {
        popupDiscount.selectItem(withTitle: value ?? "")
    }
    
    func adjustDates() {
        let selectedActivity = viewModel.getSelectedActivity()
        if selectedActivity == nil {
            fromDate.dateValue = viewModel.getProperFromDate()
            endDate.dateValue = viewModel.getProperFromDate()
            disableDates()
            return
        }
        enableDates()
        let days = selectedActivity?.days ?? 0
        fromDate.dateValue = viewModel.getProperFromDate()
        endDate.dateValue = fromDate.dateValue
        endDate.dateValue.addDays(valor: days)
    }
    
}
