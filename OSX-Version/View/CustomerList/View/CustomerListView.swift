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
    var onSelectedCustomer : ((CustomerModel) -> ())?
    
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
        self.onSelectedCustomer?(viewModel.model.registros[row])
    }
    
    @objc func newCustomerNotificationHandler(notification: Notification) {
        let obj = notification.object
        if let customer = obj as? CustomerModel {
            viewModel.model.registros.insert(customer, at: 0)
            let index = IndexSet(integer: 0)
            tableViewSocio.insertRows(at: index, withAnimation: .effectFade)
            tableViewSocio.selectRowIndexes(index, byExtendingSelection: false)
            tableViewSocio.scrollRowToVisible(0)
        }
    }
    
    func startLoading() {
        viewModel.loadCustomers()
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
        return self.viewModel.model.registros.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
      
        let cell : CustomerListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! CustomerListCell
        
        let customer = self.viewModel.model.registros[row]
    
        let apellido = customer.surname.capitalized
        let nombre = customer.name.capitalized
        let createdAt = customer.createdAt.toDate()
        let createdAtAgo = createdAt?.desdeHace(numericDates: true)
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo ?? ""
        
        viewModel.loadImage(row: row, customer: customer) { (data) in
            DispatchQueue.main.async {
                if let imageString = data, let image = imageString.convertToImage {
                    cell.fotoCell.image = image
                } else {
                    cell.fotoCell.image = #imageLiteral(resourceName: "empty")
                }
            }
        }
    
        let dni = self.viewModel.model.registros[row].dni
        cell.segundoRenglonCell.stringValue = nombre
        
        
         return cell
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            if myTable == tableViewSocio {
                let posicion = myTable.selectedRow
                self.viewModel.model.selectedCustomer = viewModel.model.registros[posicion]
                
                self.onSelectedCustomer?(viewModel.model.registros[posicion])
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

