//
//  GenericTableView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 02/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class GenericTableViewCell : NSView {
    var item = [Any]()

    static var identifier : String {
        return String(describing: self)
    }
    
    static var nib: NSNib? {
        return NSNib(nibNamed: identifier, bundle: nil)
    }
}

class GenericTableView: XibView {
    var tableview : NSTableView!
    var scrollView : NSScrollView!
    var items = [Any]()
    
    override func commonInit() {
        super .commonInit()
        
        createScrollView()
    }
    
    func createScrollView() {
        createTableView()
      
        scrollView = NSScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        scrollView.documentView = tableview
        self.addSubview(scrollView)
    }
    
    private func createTableView() {
        tableview = NSTableView(frame: .zero)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = NSColor.clear
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"))
        column.width = self.frame.width
        column.isEditable = false
        tableview.allowsColumnResizing = false
        tableview.allowsColumnReordering = false
        tableview.addTableColumn(column)
         
    }
}

extension GenericTableView : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (tableColumn?.identifier)!.rawValue == "defaultRow" else { fatalError("AdapterTableView identifier not found") }
      
        let view = GenericTableViewCell(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 100))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.yellow.cgColor
        return view
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            if myTable == tableview {
                let posicion = myTable.selectedRow
               
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
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
}
