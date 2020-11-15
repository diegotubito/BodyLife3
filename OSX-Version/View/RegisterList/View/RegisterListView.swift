//
//  RegisterListView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 11/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListView: XibViewWithAnimation , RegisterListViewContract{
   
    
    @IBOutlet weak var agregarCobroOutlet: NSButton!
    @IBOutlet weak var anularButtonOutlet: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var myIndicator : NSProgressIndicator!
    var viewModel : RegisterListViewModelContract!
    var onAddPayment : (([PaymentModel.NewRegister]) -> ())?
      
    override func commonInit() {
        super .commonInit()
        //tableView.register(RegisterCell.nib, forIdentifier: RegisterCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        self.wantsLayer = true
   //     self.layer?.backgroundColor = Constants.Colors.Gray.gray10.cgColor
        self.layer?.borderWidth = Constants.Borders.RegisterList.width
        self.layer?.borderColor = Constants.Borders.RegisterList.color
        viewModel = RegisterListViewModel(withView: self)
    }
    
    func showError(value: String) {
        DispatchQueue.main.async {
            self.showErrorConnectionView()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.removeErrorConnectionView()
            self.myIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.removeErrorConnectionView()
            self.myIndicator.stopAnimation(nil)
        }
    }
    
    func displayData() {
        DispatchQueue.main.async {
            self.tableView.deselectAll(nil)
            self.tableView.reloadData()
        }
    }
    
    func setSelectedCustomer(customer: CustomerModel.Customer) {
        viewModel.setSelectedCustomer(customer: customer)
    }
    
    func updateButtonState() {
        anularButtonOutlet.isEnabled = false
        agregarCobroOutlet.isEnabled = false
        
        guard let selection = viewModel.getSelectedRegister() else {
            return
        }
       
        let timestamp = selection.timestamp.toDate1970.toString(formato: "dd-MM-yyyy")
        let today = Date().toString(formato: "dd-MM-yyyy")
        
        let selectedRegister = viewModel.getSelectedRegister()
            
        if selection.balance ?? 0 < 0, (selectedRegister?.isEnabled)! {
            agregarCobroOutlet.isEnabled = true
        }
        if timestamp == today, (selectedRegister?.isEnabled)! {
            anularButtonOutlet.isEnabled = true
        }
        
    }
    @IBAction func anularDidPressed(_ sender: Any) {
        viewModel.cancelRegister()
    }
    @IBAction func cobroDidPressed(_ sender: Any) {
        onAddPayment?(viewModel.getPaymentsForSelectedRegister())
    }
    @IBAction func removeRegister(_ sender: Any) {
        viewModel.realDeleteEveryRelatedSellAndPayment()
    }
    
    func cancelError() {
        print("could no cancel show message")
    }
    
    func cancelSuccess() {
        viewModel.loadPayments()
        DispatchQueue.main.async {
            self.tableView.deselectAll(nil)
        }
    }
    
    func notificateStatusInfo(data: CustomerStatusModel.StatusInfo?) {
        NotificationCenter.default.post(name: .notificationUpdateStatus, object: data, userInfo: nil)
    }
    
}


extension RegisterListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.getSells().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let cell : SellRegisterCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! SellRegisterCell
        let sells = viewModel.getSells()
        let count = sells.count
        if row <= count{
            cell.displayCell(sell: sells[row])
        }
        return cell
        
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            if myTable.selectedRow == -1 {
                viewModel.setSelectedRegister(nil)
                return
            }
            let sells = viewModel.getSells()
            if myTable.selectedRow > sells.count {return}
            let selectedRegister = sells[myTable.selectedRow]
            viewModel.setSelectedRegister(selectedRegister)
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
