//
//  RegisterListView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 11/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class RegisterListView: XibView , RegisterListViewContract{
    
    @IBOutlet weak var tableView: NSTableView!
    var viewModel : RegisterListViewModelContract!
    var myActivityIndicator: NSProgressIndicator!
    
    override func commonInit() {
        super .commonInit()
        //tableView.register(RegisterCell.nib, forIdentifier: RegisterCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        self.wantsLayer = true
        self.layer?.backgroundColor = Constants.Colors.Gray.gray10.cgColor
        viewModel = RegisterListViewModel(withView: self)

        createActivityIndicator()
    }
    
    func createActivityIndicator() {
        myActivityIndicator = NSProgressIndicator(frame: NSRect(x:self.frame.width/2 - 8, y: self.frame.height-16, width: 16, height: 16))
        myActivityIndicator.style = .spinning
        myActivityIndicator.isDisplayedWhenStopped = false
         self.addSubview(myActivityIndicator)
    }
    
    func showError(value: String) {
        DispatchQueue.main.async {
            self.showErrorConnectionView()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.myActivityIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.myActivityIndicator.stopAnimation(nil)
        }
    }
    
    func displayData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setSelectedCustomer(customer: CustomerModel) {
        viewModel.setSelectedCustomer(customer: customer)
    }
    
}


extension RegisterListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.getRegisters().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let cell : SellRegisterCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! SellRegisterCell
        cell.displayCell(register: viewModel.getRegisters()[row])
        return cell
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            
            
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
