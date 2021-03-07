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
    var tableView : NSTableView!
    var items = [MainOptionModel.Item]()
    var columns = [MainOptionModel.Column]() {
        didSet {
          addConstraint()
        }
    }
    
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
    }
   
    private func setupScrollView() {
        scrollView = NSScrollView()
        scrollView.frame = .zero
        self.wantsLayer = true
        self.layer?.borderWidth = 2
        self.layer?.borderColor = NSColor.white.cgColor
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
        columns.forEach({column in
            let newColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: column.name ?? ""))
            newColumn.title = column.name ?? ""
            newColumn.width = CGFloat(column.width ?? 0) * (self.frame.width - 66)
            newColumn.headerCell.alignment = .left
            tableView.addTableColumn(newColumn)
        })
    }
    
    func addConstraint() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
      //  tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        self.setupColumn()
        
    }
    
}

extension GenericTableView: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn?.identifier.rawValue else {
            fatalError("Error in table view column identifiers")
        }
        
        
        let cell = GenericTableViewItem(frame: .zero)
        for col in columns {
            if column == col.name {
                guard let fieldName = col.fieldName else { return NSView() }
                cell.titleLabel.stringValue = getTitle(item: items[row], fieldName: fieldName)
                if col.isEditable {
                    cell.titleLabel.isEditable = true
                } else {
                    cell.titleLabel.isEditable = false
                }
                return cell
            }
        }
        
        return NSView()
    }
    
    private func getTitle(item: MainOptionModel.Item, fieldName: String) -> String {
        guard let data = try? JSONEncoder().encode(item),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return "not parsed" }
        
        let result = dictionary[fieldName]
        
        if result is String {
            return result as! String
        }
        if result is Bool {
            let stringBool = result as! Bool
            return String(stringBool)
        }
        if result is Double {
            let resultDouble = result as! Double
            return String(resultDouble)
        }
        
        return ""
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
}


class GenericTableViewItem: NSView {
    var titleLabel : NSTextField!
    
    var item : MainOptionModel.Item? {
        didSet {
            guard let item = item else { return }
            titleLabel.stringValue = item.title ?? ""
        }
    }
    
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
