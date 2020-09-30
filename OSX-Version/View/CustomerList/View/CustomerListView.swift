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
    
    @IBOutlet weak var myActivityIndicator: NSProgressIndicator!
    @IBOutlet var tableViewSocio: NSTableView!
    var needRedraw : Bool = false {
        didSet {
            if needRedraw {
                tableViewSocio.reloadData()
            }
        }
    }
    
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
        
        viewModel = CustomerListViewModel(withView: self)
        
        self.wantsLayer = true
        self.layer?.borderWidth = Constants.Borders.CustomerList.width
        self.layer?.borderColor = Constants.Borders.CustomerList.color
        
        NotificationCenter.default.addObserver(self, selector: #selector(newCustomerNotificationHandler(notification:)), name: .newCustomer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newSellNotificationHandler(notification:)), name: .needUpdateCustomerList, object: nil)
      }
    
    @objc func newSellNotificationHandler(notification: Notification) {
        let row = tableViewSocio.selectedRow
        self.onSelectedCustomer?(viewModel.model.customers[row] )
    }
    
    @objc func newCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel.Customer {
            viewModel.model.customers.insert(customer, at: 0)
            let index = IndexSet(integer: 0)
            tableViewSocio.insertRows(at: index, withAnimation: .effectFade)
            tableViewSocio.selectRowIndexes(index, byExtendingSelection: false)
            tableViewSocio.scrollRowToVisible(0)
        }
    }
    
    func startLoading() {
        viewModel.loadCustomers(offset: 0)
    }
}

extension CustomerListView: CustomerListViewContract {
    func showSuccess() {
        reloadList()
    }
    
    func showError() {
        
    }
    
    func reloadList() {
        DispatchQueue.main.async {
            self.tableViewSocio.reloadData()
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
}

extension CustomerListView: NSTableViewDataSource, NSTableViewDelegate {
   
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        return self.viewModel.model.customers.count
    }
   
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
      
        let cell : CustomerListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! CustomerListCell
        
        let customer = self.viewModel.model.customers[row]
        
        let apellido = customer.lastName.capitalized
        let nombre = customer.firstName.capitalized
        let createdAt = customer.timestamp.toDate1970
        let createdAtAgo = createdAt.desdeHace(numericDates: true)
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo
        cell.counterLabel.stringValue = String(row + 1)
      
        cell.showLoading()
        cell.fotoCell.image = #imageLiteral(resourceName: "empty")
        
        self.viewModel.loadImage(row: row, customer: customer) { (image, correctRow) in
            DispatchQueue.main.async {
                cell.hideLoading()
                if image != nil  {
                    
                    cell.fotoCell.image = image
                }
            }
        }
        
        
       
    
        cell.segundoRenglonCell.stringValue = "DNI: \(customer.dni)"
    
        let count = viewModel.model.customers.count
        if row == (count - 1){
            if count < viewModel.getTotalItems() {
                viewModel.loadCustomers(offset: count)
            }
        }
        
        return cell
    }
  
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            if myTable == tableViewSocio {
                let posicion = myTable.selectedRow
                self.viewModel.model.selectedCustomer = viewModel.model.customers[posicion]
                
                self.onSelectedCustomer?(viewModel.model.customers[posicion])
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

