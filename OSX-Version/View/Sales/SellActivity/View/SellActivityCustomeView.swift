//
//  SellActivityCustomeView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let needUpdateCustomerList = Notification.Name("needUpdateCustomerList")
    static let needUpdateProductService = Notification.Name("needUpdateProductService")
}

class SellActivityCustomView: XibViewBlurBackground, SellActivityViewContract {
    @IBOutlet var mainView: NSView!
    @IBOutlet weak var surname: NSTextField!
    @IBOutlet weak var toDate: NSDatePicker!
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var periodIndicator: NSProgressIndicator!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet weak var DiscountPopUp: NSPopUpButton!
    @IBOutlet weak var tableViewType: NSTableView!
    @IBOutlet weak var tableViewActivity: NSTableView!
    @IBOutlet weak var saveButtonView: SaveButtonCustomView!
    var viewModel : SellActivityViewModelContract!
    
    @IBOutlet weak var amountToPay: NSTextField!
    @IBOutlet weak var totalDiscount: NSTextField!
    @IBOutlet weak var scrollViewType: NSScrollView!
    override func commonInit() {
        super .commonInit()
        createBackgroundGradient()
        saveButtonView.title = "Guardar"
        disableDates()
        viewModel = SellActivityViewModel(withView: self)
        
        
        DiscountPopUp.removeAllItems()
        DiscountPopUp.addItem(withTitle: "Ninguno")
        toDate.dateValue = Date()
        fromDate.dateValue = Date()
        
        buttonSaveObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadDataHandler), name: .needUpdateProductService, object: nil)
     }
    
    override func showView() {
        super .showView()
        self.setInitialFromDate()
        self.tableViewType.reloadData()
        self.tableViewActivity.reloadData()
        self.viewModel.autoSelectType()
        self.viewModel.autoSelectActivity()
        self.viewModel.autoSelectDiscount()
    }
    
 
    @objc func loadDataHandler() {
        self.startLoading()
    }
    
    override func hideView() {
        super .hideView()
 
      //  self.viewModel.model.selectedDiscount = nil
        self.viewModel.model.selectedActivity = nil
        self.viewModel.model.selectedType = nil
        
        tableViewType.deselectAll(nil)
        tableViewActivity.deselectAll(nil)
    }
    
    func buttonSaveObserver() {
        saveButtonView.onButtonPressed = {
            if self.viewModel.validate() {
                self.viewModel.save()
            }
        }
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
    
    @IBAction func discountPopUpAction(_ sender: NSPopUpButton) {
        _ = viewModel.validate()
        viewModel.setSelectedDiscount(row: sender.indexOfSelectedItem)
        viewModel.calculateAmountToPay()
        
    }
    
    @IBAction func fromDateDidChanged(_ sender: NSDatePicker) {
        let diff = Date().diasTranscurridos(fecha: sender.dateValue)
        if diff! > 3 {
            setInitialFromDate()
            viewModel.estimateToDate()
            return
        }
        viewModel.estimateToDate()
    }
    
    @IBAction func toDateDidChanged(_ sender: NSDatePicker) {
        
    }
    
    func startLoading() {
        viewModel.loadMembership()
    }
    
    private func showCustomerInfo() {
        if viewModel.model.selectedCustomer == nil {return}
        let nameString = viewModel.model.selectedCustomer.name
        let surnameString = viewModel.model.selectedCustomer.surname
        surname.stringValue = surnameString + ", " + nameString
        
    }
    
    func disableDates() {
        fromDate.isEnabled = false
        toDate.isEnabled = false
    }
    
    func enableDates() {
        fromDate.isEnabled = true
        //         toDate.isEnabled = true
    }
    
    func setToDate(date: Date) {
        toDate.dateValue = date
    }
    
    func setInitialFromDate() {
        let expiration = viewModel.model!.selectedStatus?.expiration
        guard let doubleDate = expiration, let date = doubleDate.toDate() else {
            fromDate.dateValue = Date()
            return
        }
        
        let diff = date.diasTranscurridos(fecha: Date())
        if diff! > 10 {
            fromDate.dateValue = Date()
            return
        }
        fromDate.dateValue = date
        toDate.dateValue = date
    }
    
    func cancelPressed() {
        self.hideView()
    }
    
    func showMembershipError() {
        
    }
    
    func reloadTableViewType() {
        DispatchQueue.main.async {
            self.tableViewType.reloadData()
            self.DiscountPopUp.addItems(withTitles: self.viewModel.getDiscountTitles())
        }
    }
    
    func reloadTableViewActivity() {
        DispatchQueue.main.async {
            self.tableViewActivity.reloadData()
        }
        
    }
    
    func showLoading() {
        activityIndicator.startAnimation(nil)
        periodIndicator.startAnimation(nil)
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimation(nil)
            self.periodIndicator.stopAnimation(nil)
        }
    }
    
    func enableSaveButton() {
        DispatchQueue.main.async {
            self.didEnableSaveButton()
        }
    }
    
    func didEnableSaveButton() {
        saveButtonView.alphaValue = 1
    }
    
    func disableSaveButton() {
        DispatchQueue.main.async {
            self.didDisableSaveButton()
        }
    }
    
    func didDisableSaveButton() {
        saveButtonView.alphaValue = 0.3
    }
    
    func getFromDate() -> Date {
        return fromDate!.dateValue
    }
    
    func getToDate() -> Date {
        return toDate!.dateValue
    }
    
    func selectTypeManually(position: Int) {
        if position == -1 {return}
        let index = IndexSet(integer: position)
        
        self.tableViewType.selectRowIndexes(index, byExtendingSelection: false)
        self.tableViewType.scrollRowToVisible(position)
        //  self.tableViewType.reloadData()
   
        self.viewModel.setSelectedType(row: position)
    }
    
    func selectActivityManually(position: Int) {
        if position == -1 {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
             let index = IndexSet(integer: position)
                       self.tableViewActivity.selectRowIndexes(index, byExtendingSelection: false)
                       self.tableViewActivity.scrollRowToVisible(position)
                       _ = self.viewModel.validate()
                       self.viewModel.setSelectedActivity(row: position)
        }
           
    }
    
    func selectDiscountManually(position: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.setSelectedDiscount(row: position)
            self.DiscountPopUp.selectItem(at: position)
            _ = self.viewModel.validate()
            self.viewModel.calculateAmountToPay()
        }
        
    }
    
    func showError(_ message: String) {
        print(message)
    }
    
    func showSuccessSaving() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .needUpdateCustomerList, object: nil)
            self.hideView()
        }
    }
    
    func showSuccess() {
        showCustomerInfo()
        
        DispatchQueue.main.async {
            self.DiscountPopUp.addItems(withTitles: self.viewModel.getDiscountTitles())
            self.viewModel.calculateAmountToPay()
            self.setInitialFromDate()
                
        }
    }
    
    func displayAmountToPay(discount: Double, payment: Double) {
        totalDiscount.stringValue = discount.formatoMoneda(decimales: 2)
        amountToPay.stringValue = payment.formatoMoneda(decimales: 2)
    }
}

extension SellActivityCustomView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        if tableView == tableViewType {
            return viewModel.getTypes().count
        } else {
            return viewModel.getFilteredActivities().count
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let identificador = (tableColumn?.identifier.rawValue)!
        if tableView == tableViewType {
            if identificador == "idenActividad" {
                let activity = viewModel.getTypes()[row]
                return activity.name
            }
        } else if tableView == tableViewActivity {
            if identificador == "idenPeriodo" {
                let period = viewModel.getFilteredActivities()[row]
                return period.name
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            if myTable == tableViewType {
                viewModel.setSelectedType(row: myTable.selectedRow)
            } else if myTable == tableViewActivity {
                viewModel.setSelectedActivity(row: myTable.selectedRow)
            }
        }
    }
    
    //estos dos bloques son para cambiar el color y estilo de la seleccion
    class MyNSTableRowView: NSTableRowView {
        override func drawSelection(in dirtyRect: NSRect) {
            if self.selectionHighlightStyle != .none {
                let selectionRect = NSInsetRect(self.bounds, 0, 0)
                Constants.Colors.Blue.blueWhale.setFill()
                let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 10, yRadius: 10)
                selectionPath.fill()
                selectionPath.stroke()
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MyNSTableRowView()
    }
}
