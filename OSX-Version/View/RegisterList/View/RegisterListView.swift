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
            self.myIndicator.startAnimation(nil)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.myIndicator.stopAnimation(nil)
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
    
    func updateButtonState() {
        anularButtonOutlet.isEnabled = false
        agregarCobroOutlet.isEnabled = false
        
        guard let selection = viewModel.getSelectedRegister() else {
            return
        }
       
        let createdAt = selection.createdAt.toDate()
        let today = Calendar.current.component(.day, from: Date())
        let createdDay = Calendar.current.component(.day, from: createdAt!)
        let selectedRegister = viewModel.getSelectedRegister()
            
        if selection.balance ?? 0 < 0, (selectedRegister?.isEnabled)! {
            agregarCobroOutlet.isEnabled = true
        }
        if createdDay == today, (selectedRegister?.isEnabled)! {
            anularButtonOutlet.isEnabled = true
        }
        
    }
    @IBAction func anularDidPressed(_ sender: Any) {
        viewModel.cancelRegister()
    }
    @IBAction func cobroDidPressed(_ sender: Any) {
    }
    
    func cancelError() {
        
    }
    
    func cancelSuccess() {
        let row = tableView.selectedRow
        viewModel.setIsEnabled(row: row)
        tableView.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
        tableView.insertRows(at: IndexSet(integer: row), withAnimation: .effectGap)
        NotificationCenter.default.post(.init(name: .notificationArticleDidChanged))
    }
    
}


extension RegisterListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.getRegisters().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let cell : SellRegisterCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! SellRegisterCell
        let registers = viewModel.getRegisters()
        if row <= registers.count{
            cell.displayCell(register: viewModel.getRegisters()[row])
        } else {
            print("safe exit")
        }
        return cell
        
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            if myTable.selectedRow == -1 {
                viewModel.setSelectedRegister(nil)
                return
            }
            let selectedRegister = viewModel.getRegisters()[myTable.selectedRow]
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
