//
//  Collapsable.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 22/12/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class CollapsableView : XibView {
    var tableview : NSTableView!
    var scrollView : NSScrollView!
    var items = [[Any]]()
    
    override func commonInit() {
        super .commonInit()
        createScrollView()
        tableview.rowHeight = 150
    }
    
    func loadValues() {
        items.removeAll()
        for h in 0...5 {
            var cells = [String]()
            for c in 0...3 {
                cells.append("Diego")
            }
            items.append(cells)
        }
        tableview.reloadData()
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

extension CollapsableView: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = GenericTableViewCell(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 200))
        view.wantsLayer = true
        if ((row % 2) != 0) {
            view.layer?.backgroundColor = NSColor.lightGray.cgColor
        } else {
            view.layer?.backgroundColor = NSColor.gray.cgColor
            
        }
        return view
    }
}
