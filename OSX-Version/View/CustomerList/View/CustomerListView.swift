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
        
    }
    
    func startLoading() {
        viewModel.loadCustomers()
    }
}


extension CustomerListView: CustomerListViewContract {
    func reloadList() {
        DispatchQueue.main.async {
            self.tableViewSocio.reloadData()
        }
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
    
    
}


extension CustomerListView: NSTableViewDataSource, NSTableViewDelegate {
   
    func numberOfRows(in tableView: NSTableView) -> Int {
        if viewModel == nil {return 0}
        return self.viewModel.model.registros.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
      
        let cell : CustomerListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! CustomerListCell
    
        let apellido = self.viewModel.model.registros[row].surname.capitalized
        let nombre = self.viewModel.model.registros[row].name.capitalized
        let createdAt = self.viewModel.model.registros[row].createdAt.toDate()
        let createdAtAgo = createdAt?.desdeHace(numericDates: true)
        cell.primerRenglonCell.stringValue = apellido + ", " + nombre
        cell.timeAgoCell.stringValue = createdAtAgo ?? ""
        
        DispatchQueue.global().async {
            let image64String = self.viewModel.model.registros[row].thumbnailImage
            let image = image64String?.convertToImage
            DispatchQueue.main.async {
                cell.fotoCell.image = image ?? #imageLiteral(resourceName: "empty")
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

