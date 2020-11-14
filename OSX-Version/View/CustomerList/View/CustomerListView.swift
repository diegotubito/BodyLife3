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
        if row == -1 {return}
        let customer = viewModel.model.bySearch ? viewModel.model.customersbySearch[row] : viewModel.model.customersbyPages[row]
        
        self.onSelectedCustomer?(customer)
    }
    
    @objc func newCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel.Customer {
            let image = customer.thumbnailImage?.convertToImage
            viewModel.model.customersbyPages.insert(customer, at: 0)
            viewModel.model.imagesByPages.insert(CustomerListModel.Images(image: image, _id: customer._id), at: 0)
           
            let index = IndexSet(integer: 0)
            viewModel.model.selectedCustomer = customer
            tableViewSocio.scrollRowToVisible(0)
            tableViewSocio.selectRowIndexes(index, byExtendingSelection: false)
            tableViewSocio.reloadData()
        }
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
            if !searchField.stringValue.isEmpty {
                viewModel.model.bySearch = true
                viewModel.loadCustomers(bySearch: searchField.stringValue, offset: 0)
            } else {
                viewModel.model.bySearch = false
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
        let createdAtAgo = createdAt.desdeHace(numericDates: true) + " \(createdAt.toString(formato: "dd-MM-yyyy HH:mm"))"
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo
        cell.counterLabel.stringValue = String(row + 1)
        cell.segundoRenglonCell.stringValue = "uid: \(customers[row].uid)"
        
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
        if row == (count - 1) - 25 {
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
            let indexSet = IndexSet(integer: row)
            let indexSetColumn = IndexSet(integer: 0)
            self.tableViewSocio.reloadData(forRowIndexes: indexSet, columnIndexes: indexSetColumn)
        }
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
             if myTable == tableViewSocio {
                let posicion = myTable.selectedRow
                if posicion == -1 {return}
                let customer = viewModel.model.bySearch ? viewModel.model.customersbySearch[posicion] : viewModel.model.customersbyPages[posicion]
                self.viewModel.model.selectedCustomer = customer
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

