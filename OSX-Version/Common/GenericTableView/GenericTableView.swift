//
//  GenericTableView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 02/01/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//
import Cocoa
import Foundation

struct GenericTableViewColumnModel : Codable {
    var type: String?
    var rowHeight: CGFloat?
    var columns: [Column] = []
    
    struct Column: Codable {
        var isEditable: Bool
        var width: Double?
        var maxWidth: Double?
        var minWidth: Double?
        var fieldName: String?
        var dateFormat: String?
        var type: String?
    }
    
    struct RequestData: Codable {
        var path: String
        var subpath: String?
        var method: String
        var query: String?
        var body: String?
    }
    
    enum ColumnType: String {
        case string = "string"
        case bool = "bool"
        case double = "double"
        case date = "date"
        case currency = "currency"
        case int = "int"
        case popup_secondary_user = "popup_secondary_user"
        case popup_bool = "popup_bool"
    }
    
    enum ViewcontrollerType: String, Codable {
        case general = "general"
    }
}

protocol GenericTableViewDelegate: AnyObject {
    func textFieldDidChanged(row: Int, columnIdentifier: String, stringValue: String)
    func selectedRow(row: Int)
}

extension GenericTableViewDelegate {
    func textFieldDidChanged(row: Int, columnIdentifier: String, stringValue: String) {
        // Optional
    }
}

class GenericTableView<U: GenericTableViewItem> : NSView, NSTableViewDelegate, NSTableViewDataSource {
    var scrollView : NSScrollView!
    var tableView : NSTableView!
    var items = [[String: Any]]() {
        didSet {
            tableView.reloadData()
        }
    }
    var column = GenericTableViewColumnModel() {
        didSet {
            DispatchQueue.main.async {
                self.setupColumn()
            }
        }
    }
    var activityIndicator: NSProgressIndicator!
    
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
        setupActivityIndicator()
    }
    
    func setActivityIndicator(_ value: Bool) {
        activityIndicator.isHidden = !value
    }
    
    private func setupActivityIndicator() {
        activityIndicator = NSProgressIndicator(frame: CGRect.zero)
        activityIndicator.isDisplayedWhenStopped = false
        activityIndicator.style = .spinning
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
        ])
    }
    
    private func setupScrollView() {
        scrollView = NSScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.wantsLayer = true
        self.layer?.borderWidth = 2
        self.layer?.borderColor = NSColor.white.cgColor
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    private func setupTableView() {
        tableView = NSTableView()
        tableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        tableView.delegate = self
        tableView.dataSource  = self
        tableView.allowsColumnResizing = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnReordering = false
        tableView.appearance = NSAppearance(named: NSAppearance.Name.darkAqua)
        scrollView.documentView = tableView
    }
    
    func setupColumn() {
        column.columns.forEach({column in
            let newColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: column.fieldName ?? ""))
            newColumn.title = column.fieldName ?? ""
            newColumn.width = CGFloat(column.width ?? 0) * (self.frame.width - CGFloat(self.column.columns.count) * 20)
            newColumn.headerCell.alignment = .left
            
            tableView.addTableColumn(newColumn)
        })
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnName = tableColumn?.identifier.rawValue else {
            fatalError("Error in table view column identifiers")
        }
        
        for col in self.column.columns {
            if columnName == col.fieldName {
                let cell = U(frame: .zero, column: col)
                cell.textFieldDidChangedObserver = { [weak self] columnIdentifier, stringValue in
                    self?.delegate?.textFieldDidChanged(row: row, columnIdentifier: columnIdentifier, stringValue: stringValue)
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
        switch GenericTableViewColumnModel.ColumnType(rawValue: format) {
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
        case .popup_secondary_user:
            guard let title = dictionary[fieldName] as? String else { return "" }
            return title
        case .popup_bool:
            guard let title = dictionary[fieldName] as? Bool else { return "true" }
            return String(title)
        }
        
        return ""
    }
    
    func getType() -> String {
        return column.type ?? "no type"
    }
    
    func isPopUp() -> Bool {
        switch getType() {
        case GenericTableViewColumnModel.ColumnType.popup_secondary_user.rawValue, GenericTableViewColumnModel.ColumnType.popup_bool.rawValue:
            return true
        default:
            return false
        }
    }
    
    func setStatus(label: NSTextField) {
        label.isEditable = column.isEditable
        label.isBezeled = column.isEditable
    }
    
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        textFieldDidChangedObserver?(columnIdentifier, stringValue)
    }
}

