//
//  GenericTableView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 02/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Cocoa

struct GenericTableViewColumnModel : Codable {
    var type: String?
    var rowHeight: CGFloat?
    var columns: [Column] = []
    
    struct Column: Codable {
        var name: String?
        var isEditable: Bool
        var width: Double?
        var maxWidth: Double?
        var minWidth: Double?
        var fieldName: String?
        var dateFormat: String?
        var type: String?
    }
}

protocol GenericTableViewDelegate: AnyObject {
    func textFieldDidChanged(columnIdentifier: String, stringValue: String)
    func selectedRow(row: Int)
}

extension GenericTableViewDelegate {
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        // Optional
    }
}

class GenericTableView<U: GenericTableViewItem> : NSView, NSTableViewDelegate, NSTableViewDataSource {
    var scrollView : NSScrollView!
    var tableView : NSTableView!
    var items = [[String: Any]]()
    var column = GenericTableViewColumnModel() {
        didSet {
          addConstraint()
        }
    }
    
    weak var delegate: GenericTableViewDelegate?
    
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
        column.columns.forEach({column in
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnName = tableColumn?.identifier.rawValue else {
            fatalError("Error in table view column identifiers")
        }
        
        for col in self.column.columns {
            if columnName == col.name {
                let cell = U(frame: .zero, column: col)
                cell.textFieldDidChangedObserver = { [weak self] columnIdentifier, stringValue in
                    self?.delegate?.textFieldDidChanged(columnIdentifier: columnIdentifier, stringValue: stringValue)
                }
                cell.item = items[row]
                return cell
            }
        }
        
        return NSView()
    }
   
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return column.rowHeight ?? 0.0
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.delegate?.selectedRow(row: tableView.selectedRow)
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}

class GenericTableViewItem: NSView {
    var item : [String: Any]!
    var column: GenericTableViewColumnModel.Column!
    var textFieldDidChangedObserver : ((String, String) -> ())?
    
    required init(frame frameRect: NSRect, column: GenericTableViewColumnModel.Column) {
        super .init(frame: frameRect)
        self.column = column
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("xib file not implemented")
    }
    
    func commonInit() {
    }
   
    func getTitle(dictionary: [String: Any], fieldName: String) -> String {
        guard let format = column.type else { return "no econtro type" }
        switch ColumnType(rawValue: format) {
        case .int:
            guard let intValue = dictionary[fieldName] as? Int else {return ""}
            return String(intValue)
        case .bool:
            guard let boolValue = dictionary[fieldName] as? Bool else {return ""}
            return String(boolValue)
        case .double:
            guard let doubleValue = dictionary[fieldName] as? Double else {return ""}
            return String(doubleValue)
        case .string:
            let stringValue = dictionary[fieldName] as? String
            return stringValue ?? ""
        case .date:
            let dateFormat = column.dateFormat
            let doubleValue =  dictionary[fieldName] as? Double
            let date = doubleValue?.toDate1970
            let stringDate = date?.toString(formato: dateFormat ?? "dd-MM-yyyy")
            return stringDate ?? ""
        case .currency:
            guard let doubleValue = dictionary[fieldName] as? Double else {return ""}
            return doubleValue.currencyFormat(decimal: 2)
        case .none:
            break
        }
        
        return ""
    }
    
    func setStatus(label: NSTextField) {
        label.isEditable = column.isEditable
        label.isBezeled = column.isEditable
    }
    
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        textFieldDidChangedObserver?(columnIdentifier, stringValue)
    }
}


enum ColumnType: String {
    case string = "string"
    case bool = "bool"
    case double = "double"
    case date = "date"
    case currency = "currency"
    case int = "int"
}
