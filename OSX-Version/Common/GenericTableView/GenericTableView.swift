//
//  GenericTableView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 02/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Cocoa

class GenericTableView : NSView {
    var scrollView : NSScrollView!
    var defaultColumn : NSTableColumn!
    var tableView : NSTableView!
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setupScrollView()
        setupTableView()
        setupColumn()
        addConstraint()
    }
   
    private func setupScrollView() {
        scrollView = NSScrollView()
        scrollView.frame = self.bounds
        self.addSubview(scrollView)
    }
    
    private func setupTableView() {
        tableView = NSTableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource  = self
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnReordering = false
        
        scrollView.documentView = tableView
    }
    
    func setupColumn() {
        defaultColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "defaultColumn"))
        defaultColumn.title = "Opciones"
        tableView.addTableColumn(defaultColumn)
    }
    
    func addConstraint() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        defaultColumn.minWidth = self.bounds.width * 0.89
        
    }
    
}

extension GenericTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 20
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn?.identifier.rawValue else {
            fatalError("Error in table view column identifiers")
        }
        
        switch column {
        case "defaultColumn":
            
            let cell = GenericTableViewItem(frame: .zero)
            cell.titleLabel.stringValue = "Estamos probando con un texto muy largo"
            
            return cell
        default:
            return NSView()
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
}


class GenericTableViewItem: NSView {
    var titleLabel : NSTextField!
    
    override init(frame frameRect: NSRect) {
        super .init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("xib file not implemented")
    }
    
    private func commonInit() {
        addTitle()
        addContraints()
    }
    
    private func addTitle() {
        titleLabel = NSTextField(frame: CGRect.zero)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.maximumNumberOfLines = 0
        self.addSubview(titleLabel)
    }
    
    private func addContraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
    }
}
