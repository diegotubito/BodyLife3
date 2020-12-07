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
    var onSelectedCustomer : ((CustomerModel.Customer?) -> ())?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(updatedCustomerNotificationHandler(notification:)), name: .updatedCustomer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newSellNotificationHandler(notification:)), name: .needUpdateCustomerList, object: nil)
    
    }
    
    @objc func newSellNotificationHandler(notification: Notification) {
        let row = tableViewSocio.selectedRow
        if row == -1 {return}
        let customer = viewModel.model.bySearch ? viewModel.model.customersbySearch[row] : viewModel.model.customersbyPages[row]
        
        self.onSelectedCustomer?(customer)
    }
    
    @objc func newCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel.Customer {
            insertNewCustomerInTableView(customer: customer, row: 0)
            self.onSelectedCustomer?(customer)
        }
    }
    
    @objc func updatedCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel.Customer {
            updateCustomerInTableView(customer: customer, row: 0)
            self.onSelectedCustomer?(customer)
        }
    }
    
    func insertNewCustomerInTableView(customer: CustomerModel.Customer, row: Int) {
        let image = customer.thumbnailImage?.convertToImage
        viewModel.model.customersbyPages.insert(customer, at: row)
        viewModel.model.imagesByPages.insert(CustomerListModel.Images(image: image, _id: customer._id!), at: row)
        viewModel.model.selectedCustomer = customer
        
        if viewModel.model.bySearch {
            viewModel.model.bySearch = false
            searchField.stringValue = ""
            searchField.resignFirstResponder()
            reloadList()
            return
        } else {
            let index = IndexSet(integer: row)
            tableViewSocio.beginUpdates()
            tableViewSocio.insertRows(at: index, withAnimation: .effectGap)
            tableViewSocio.scrollRowToVisible(row)
            tableViewSocio.selectRowIndexes(index, byExtendingSelection: false)
            tableViewSocio.endUpdates()
        }
    }
    
    func updateCustomerInTableView(customer: CustomerModel.Customer, row: Int) {
        if let rowByPage = viewModel.model.customersbyPages.firstIndex(where: {$0._id == customer._id}) {
            viewModel.model.customersbyPages[rowByPage] = customer
        }
        if let rowBySearch = viewModel.model.customersbySearch.firstIndex(where: {$0._id == customer._id}) {
            viewModel.model.customersbySearch[rowBySearch] = customer
            
        }
        if let thumbnail = customer.thumbnailImage {
            viewModel.setImageForCustomer(_id: customer._id!, thumbnail: thumbnail)
        }
        viewModel.model.selectedCustomer = customer
        viewModel.model.bySearch = false
        searchField.stringValue = ""
        searchField.resignFirstResponder()
        reloadList()
        return
    }
    
    func startLoading() {
        resetValues()
        viewModel.loadCustomers(offset: 0)
    }
    
    private func resetValues() {
        viewModel.model.selectedCustomer = nil
        viewModel.model.customersbyPages.removeAll()
        viewModel.model.customersbySearch.removeAll()
        viewModel.model.imagesByPages.removeAll()
        viewModel.model.imagesBySearch.removeAll()
       
        DispatchQueue.main.async {
            self.tableViewSocio.reloadData()
        }
    }
    
    @IBAction func searchFieldDidChanged(_ sender: NSSearchField) {
       
    }
}

extension CustomerListView: NSSearchFieldDelegate {
  
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
     
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            tableViewSocio.deselectAll(nil)
            viewModel.model.selectedCustomer = nil
            onSelectedCustomer?(nil)

            if !searchField.stringValue.isEmpty {
                viewModel.model.bySearch = true
                viewModel.model.stopLoading = false
                viewModel.loadCustomers(bySearch: searchField.stringValue, offset: 0)
            } else {
                viewModel.model.stopLoading = false
                viewModel.model.bySearch = false
                reloadList()
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
        reloadList()
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
    
    func reloadList() {
        DispatchQueue.main.async {
            self.tableViewSocio.beginUpdates()
            self.tableViewSocio.reloadData()
            self.tableViewSocio.endUpdates()
            self.selectCustomerInTableView()
        }
    }
    
    func selectCustomerInTableView() {
        // hay que volver a seleccionar el customer, ya que el reloaddata deselecciona la tabla.
        let customer = self.viewModel.model.selectedCustomer
        if customer != nil {
            if let row = self.viewModel.model.customersbyPages.firstIndex(where: {$0._id == customer?._id}) {
                self.tableViewSocio.selectRowIndexes(IndexSet([row]), byExtendingSelection: false)
            }
        } else {
            self.tableViewSocio.deselectAll(nil)
        }
    }
    
    func scrollToSelectedCustomer() {
        let row = tableViewSocio.selectedRow
        tableViewSocio.scrollRowToVisible(row)
    }
}

extension CustomerListView: NSTableViewDataSource, NSTableViewDelegate {
   
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        let customers = viewModel.model.bySearch ? viewModel.model.customersbySearch : viewModel.model.customersbyPages
        return customers.count
    }
   
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
      
        let cell : CustomerListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! CustomerListCell
        
        let customers = viewModel.model.bySearch ? viewModel.model.customersbySearch : viewModel.model.customersbyPages
        let images = viewModel.model.bySearch ? viewModel.model.imagesBySearch : viewModel.model.imagesByPages
        
        let apellido = customers[row].lastName.capitalized
        let nombre = customers[row].firstName.capitalized
        let createdAt = customers[row].timestamp.toDate1970
        let createdAtAgo = createdAt.desdeHace(numericDates: true) + "\n\(createdAt.toString(formato: "dd-MM-yyyy"))"
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo
        cell.segundoRenglonCell.stringValue = "Cel: \(customers[row].phoneNumber)"
        
        cell.fotoCell.image = nil
        cell.showLoading()
        let loadedImage = images.filter({$0._id == customers[row]._id})
        if loadedImage.count > 0 {
            cell.hideLoading()
            if let image = loadedImage[0].image {
                cell.fotoCell.image = image
            } else {
                cell.fotoCell.image = #imageLiteral(resourceName: "empty")
            }
        }
        
        let count = customers.count
        if row == (count - 1) - (viewModel.model.limit/2) || row == (count - 1) {
            if viewModel.model.bySearch {
                viewModel.loadCustomers(bySearch: searchField.stringValue, offset: count)
            } else {
                viewModel.loadCustomers(offset: count)
            }
        }
        
        return cell
    }
    
    func reloadCell(row: Int) {
        DispatchQueue.main.async {
            self.tableViewSocio.beginUpdates()
            let indexSet = IndexSet(integer: row)
            let indexSetColumn = IndexSet(integer: 0)
            self.tableViewSocio.reloadData(forRowIndexes: indexSet, columnIndexes: indexSetColumn)
            self.tableViewSocio.endUpdates()
        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            print("selection changed")
             if myTable == tableViewSocio {
                let posicion = myTable.selectedRow
                
                if posicion == -1 {return}
                let customer = viewModel.model.bySearch ? viewModel.model.customersbySearch[posicion] : viewModel.model.customersbyPages[posicion]
                if self.viewModel.model.selectedCustomer?._id != customer._id {
                    self.viewModel.model.selectedCustomer = customer
                    if let customer = viewModel.model.selectedCustomer {
                        self.onSelectedCustomer?(customer)
                    }
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
                let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
                selectionPath.fill()
                selectionPath.stroke()
                
            }
            
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MyNSTableRowView()
    }
}

