//
//  CustomerListView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 18/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa


class CustomerListView: NSView {
    @IBOutlet var myView: NSView!
    @IBOutlet weak var searchField : NSSearchField!
    @IBOutlet weak var myActivityIndicator: NSProgressIndicator!
    @IBOutlet var tableViewSocio: NSTableView!
    
    var viewModel : CustomerListViewModelContract!
    var onSelectedCustomer : ((CustomerModel.Customer) -> ())?
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        inicializar()
    }
    
    required init?(coder decoder: NSCoder) {
        super .init(coder: decoder)
        inicializar()
    }
    
    deinit {
        print("BLListadoSocioView deinit")
    }
    
    func inicializar() {
        Bundle.main.loadNibNamed("CustomerListCell", owner: self, topLevelObjects: nil)
        myView.frame = self.frame
        addSubview(myView)

        tableViewSocio.delegate = self
        tableViewSocio.dataSource = self
        searchField.delegate = self
        viewModel = CustomerListViewModel(withView: self)
        
        self.wantsLayer = true
        self.layer?.borderWidth = Constants.Borders.CustomerList.width
        self.layer?.borderColor = Constants.Borders.CustomerList.color
        
        NotificationCenter.default.addObserver(self, selector: #selector(newCustomerNotificationHandler(notification:)), name: .newCustomer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newSellNotificationHandler(notification:)), name: .needUpdateCustomerList, object: nil)
    
    }
    
    @objc func newSellNotificationHandler(notification: Notification) {
        let row = tableViewSocio.selectedRow
        self.onSelectedCustomer?(viewModel.model.customersToDisplay[row] )
    }
    
    @objc func newCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel.Customer {
            viewModel.model.customersToDisplay.insert(customer, at: 0)
            viewModel.model.customersbyPages.insert(customer, at: 0)
            let index = IndexSet(integer: 0)
            
            tableViewSocio.beginUpdates()
            tableViewSocio.insertRows(at: index, withAnimation: .effectFade)
            tableViewSocio.selectRowIndexes(index, byExtendingSelection: false)
            tableViewSocio.scrollRowToVisible(0)
            tableViewSocio.endUpdates()
        }
    }
    
    func startLoading() {
        viewModel.loadCustomers(offset: 0)
    }
    
    @IBAction func searchFieldDidChanged(_ sender: NSSearchField) {
        print("did changed")
    }
}

extension CustomerListView: NSSearchFieldDelegate {
  
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
     
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            if !searchField.stringValue.isEmpty {
                viewModel.switchLoadingCustomers(bySearch: true)
                viewModel.loadCustomers(bySearch: searchField.stringValue, offset: 0)
            } else {
                viewModel.switchLoadingCustomers(bySearch: false)
                tableViewSocio.reloadData()
            }
        }
        if (commandSelector == #selector(NSResponder.deleteBackward(_:)) ) {
            if !searchField.stringValue.isEmpty {
                searchField.stringValue.removeLast()
            }
        }
        return true
    }
}

extension CustomerListView: CustomerListViewContract {
    func showSuccess() {
        DispatchQueue.main.async {
            self.tableViewSocio.beginUpdates()
            self.tableViewSocio.reloadData()
            self.tableViewSocio.endUpdates()
        }
    }
    
    func showError() {
        
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
}

extension CustomerListView: NSTableViewDataSource, NSTableViewDelegate {
   
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        return self.viewModel.model.customersToDisplay.count
    }
   
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
      
        let cell : CustomerListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! CustomerListCell
        
        let customer = self.viewModel.model.customersToDisplay[row]
        
        let apellido = customer.lastName.capitalized
        let nombre = customer.firstName.capitalized
        let createdAt = customer.timestamp.toDate1970
        let createdAtAgo = createdAt.desdeHace(numericDates: true)
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo
        cell.counterLabel.stringValue = String(row + 1)
        cell.segundoRenglonCell.stringValue = "Cel: \(customer.phoneNumber)"
        
        cell.fotoCell.image = nil
        cell.showLoading()
        let loadedImage = viewModel.model.imagesToDisplay.filter({$0._id == customer._id})
        if loadedImage.count > 0 {
            cell.hideLoading()
            if let image = loadedImage[0].image {
                cell.fotoCell.image = image
            } else {
                cell.fotoCell.image = #imageLiteral(resourceName: "empty")
            }
        }
        
        let count = viewModel.model.customersToDisplay.count
        if row == (count - 1) - 25 {
            if count < viewModel.getTotalItems() {
                if viewModel.model.bySearch {
                    viewModel.switchLoadingCustomers(bySearch: true)
                    viewModel.loadCustomers(bySearch: searchField.stringValue, offset: count)
                } else {
                    viewModel.switchLoadingCustomers(bySearch: false)
                    viewModel.loadCustomers(offset: count)
                }
            }
        }
        
        return cell
    }
    
    func reloadCell(row: Int) {
        DispatchQueue.main.async {
            let indexSet = IndexSet(integer: row)
            let indexSetColumn = IndexSet(integer: 0)
            self.tableViewSocio.reloadData(forRowIndexes: indexSet, columnIndexes: indexSetColumn)
        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
             if myTable == tableViewSocio {
                let posicion = myTable.selectedRow
                self.viewModel.model.selectedCustomer = viewModel.model.customersToDisplay[posicion]
                if viewModel.model.selectedCustomer != nil {
                    self.onSelectedCustomer?(viewModel.model.selectedCustomer!)
                }
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

