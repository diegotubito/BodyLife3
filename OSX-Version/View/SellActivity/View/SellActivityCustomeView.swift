//
//  SellActivityCustomeView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let newSell = Notification.Name("newSell")
}

class SellActivityCustomView: XibView, SellActivityViewContract {
    @IBOutlet weak var surname: NSTextField!
    @IBOutlet weak var amountTextField: NSTextField!
    @IBOutlet weak var toDate: NSDatePicker!
    @IBOutlet weak var fromDate: NSDatePicker!
    @IBOutlet weak var periodIndicator: NSProgressIndicator!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet weak var DiscountPopUp: NSPopUpButton!
    @IBOutlet weak var tableViewActivity: NSTableView!
    @IBOutlet weak var tableViewPeriodo: NSTableView!
    @IBOutlet weak var titleView: NSView!
    var saveButtonView: SaveButtonCustomView!
    var xButtonView : XButtonCustomView!
    var viewModel : SellActivityViewModelContract!
    
    @IBOutlet weak var dateLineSeparator: NSImageView!
    override func commonInit() {
        super .commonInit()
        disableDates()
        viewModel = SellActivityViewModel(withView: self)
        
        DispatchQueue.main.async {
            self.addDateSeparator()
            self.addSaveButton()
            self.setupTitleView()
            self.addXButton()
            _ = self.viewModel.validate()
        }
        DiscountPopUp.removeAllItems()
        DiscountPopUp.addItem(withTitle: "Ninguno")
    }
    
    func addDateSeparator() {
        dateLineSeparator.wantsLayer = true
        dateLineSeparator.layer?.backgroundColor = NSColor.darkGray.cgColor
    }
    
    func setupTitleView() {
        titleView.wantsLayer = true
        titleView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
    }
    
    func addSaveButton() {
        saveButtonView = SaveButtonCustomView(frame: CGRect(x: (self.frame.width - 75) / 2, y: 16, width: 75, height: 75))
        saveButtonView.didButtonPressed = {
            self.savePressed()
        }
        self.addSubview(saveButtonView)
    }
    
    func addXButton() {
        self.xButtonView = XButtonCustomView(frame: CGRect(x: self.titleView.frame.width - 16 - 40, y: self.titleView.frame.height / 2 - 20, width: 40, height: 40))
        self.titleView.addSubview(self.xButtonView)
        self.xButtonView.didButtonPressed = {
            self.cancelPressed()
        }
    }
    
    @IBAction func discountPopUpAction(_ sender: NSPopUpButton) {
        _ = viewModel.validate()
        viewModel.setSelectedDiscount(row: sender.indexOfSelectedItem)
    }
    
    @IBAction func fromDateDidChanged(_ sender: NSDatePicker) {
        viewModel.estimateToDate()
    }
    
    @IBAction func toDateDidChanged(_ sender: NSDatePicker) {
    }
    
    func startLoading() {
        setInitialValues()
        viewModel.loadMembership()
    }
    
    private func setInitialValues() {
        let nameString = viewModel.model.selectedCustomer.name
        let surnameString = viewModel.model.selectedCustomer.surname
        surname.stringValue = surnameString + ", " + nameString
        amountTextField.stringValue = ""
        tableViewActivity.deselectAll(nil)
        tableViewPeriodo.deselectAll(nil)
        self.viewModel.autoSelectActivity()
        setInitialFromDate()
        self.viewModel.estimateToDate()
    }
    
    func disableDates() {
        fromDate.isEnabled = false
        toDate.isEnabled = false
    }
    
    func enableDates() {
          fromDate.isEnabled = true
          toDate.isEnabled = true
      }
    
    func setToDate(date: Date) {
        toDate.dateValue = date
    }
       
    func setInitialFromDate() {
        let expiration = viewModel.model!.selectedStatus?.expiration
        guard let doubleDate = expiration else {
            fromDate.dateValue = Date()
            return
        }
        guard let date = doubleDate.toDate() else {
            fromDate.dateValue = Date()
            return
        }
        let diff = date.diasTranscurridos(fecha: Date())
        if diff! > 10 {
            fromDate.dateValue = Date()
            return
        }
        fromDate.dateValue = date
    }
    
    func savePressed() {
        if viewModel.validate() {
            viewModel.save()
        }
    }
    
    func cancelPressed() {
        animateMode = .fadeOut
    }
    
    func showMembershipError() {
        DispatchQueue.main.async {
            self.showErrorConnectionView()
        }
    }
    
    func reloadView() {
        DispatchQueue.main.async {
            self.tableViewActivity.reloadData()
            self.selectActivityManually(position: 0)
            self.DiscountPopUp.addItems(withTitles: self.viewModel.getDiscountTitles())
        }
    }
    
    func reloadPeriod() {
        DispatchQueue.main.async {
            self.tableViewPeriodo.reloadData()
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
    
    func getAmount() -> String {
        return amountTextField.stringValue
    }
    
    func selectActivityManually(position: Int) {
        if position == -1 {return}
        DispatchQueue.main.async {
            let index = IndexSet(integer: position)
            self.tableViewActivity.selectRowIndexes(index, byExtendingSelection: false)
            self.tableViewActivity.scrollRowToVisible(position)
        }
    }
    
    func showAmount(value: Double) {
        self.amountTextField.stringValue = String(value.rounded(toPlaces: 2))
    }
    
    func showError(_ message: String) {
        print(message)
    }
    
    func showSuccess() {
        NotificationCenter.default.post(name: .newSell, object: nil)
        animateMode = .fadeOut
    }
}

extension SellActivityCustomView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        if tableView == tableViewActivity {
            return viewModel.getActivities().count
        } else {
            return viewModel.getFilteredPeriods().count
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let identificador = (tableColumn?.identifier.rawValue)!
        if tableView == tableViewActivity {
            if identificador == "idenActividad" {
                let activity = viewModel.getActivities()[row]
                return activity.name
            }
        } else if tableView == tableViewPeriodo {
            if identificador == "idenPeriodo" {
                let period = viewModel.getFilteredPeriods()[row]
                return period.name
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            if myTable == tableViewActivity {
                viewModel.setSelectedActivity(row: myTable.selectedRow)
            } else if myTable == tableViewPeriodo {
                viewModel.setSelectedPeriod(row: myTable.selectedRow)
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
