//
//  SettingsGeneralViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 19/09/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa
import BLServerManager

class SettingsGeneralViewController: NSViewController {
    struct Input {
        let info: SettingModel.ViewControllerModel
    }
    
    struct Constants {
        static let defaultBackgroundColor = "#000000"
        struct Parameters {
            static let backgroundColor = "backgroundColor"
        }
    }
    
    var input: Input!
    var singleLabelTableView: SingleLabelTableView!
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let color = input.info.backgroundColor
        view.layer?.backgroundColor = NSColor(hexString: color).cgColor
        
       loadData()
    }
    
    private func drawCustomTableView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        guard let encodedData = try? JSONEncoder().encode(input.info.column),
              let jsonString = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any]
        else { return }
        singleLabelTableView = SingleLabelTableView(frame: frame, columns: jsonString)
        singleLabelTableView.delegate = self
        view.addSubview(singleLabelTableView)
    }
    
    func loadData() {
        let uid = MainUserSession.GetUID()
        let path = input.info.request?.path ?? "need path"
        
        var url = ""
        if let subpath = input.info.request?.subpath {
            url = "\(BLServerManager.baseUrl.rawValue)\(subpath):\(uid):\(path)"
        } else {
            url = "\(BLServerManager.baseUrl.rawValue)\(input.info.request?.path ?? "no path")"
        }
        let request = BLEndpointModel(url: url,
                                token: MainUserSession.GetToken(),
                                tokenSecondaryUser: SecondaryUserSession.GetUser()?.token,
                                method: input.info.request?.method ?? "need method",
                                query: nil,
                                body: nil)
        
        BLServerManager.ApiCall(endpoint: request) { response in
            guard
                let data = response,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let jsonArray = json["data"] as? [[String: Any]]
            else { return }
            DispatchQueue.main.async {
                self.drawCustomTableView()
                self.singleLabelTableView.items = jsonArray
                self.singleLabelTableView.showItems()
            }
        } fail: { (error) in
            DispatchQueue.main.async {
                if self.singleLabelTableView != nil {
                    self.singleLabelTableView.removeFromSuperview()
                }
            }
        }
    }
    
    func updateData(newValue: [String: Any], row: Int) {
        let uid = MainUserSession.GetUID()
        let path = input.info.request?.path ?? "need path"
        guard let _id = newValue["_id"] as? String else {
            print("could not update value")
            return
        }
        
        var url = ""
        var query: String?
        if let subpath = input.info.request?.subpath {
            url = "\(BLServerManager.baseUrl.rawValue)\(subpath):\(uid):\(path):\(_id)"
        } else {
            url = "\(BLServerManager.baseUrl.rawValue)\(input.info.request?.path ?? "no path")/"
            query = "?_id=\(_id)"
        }
        let request = BLEndpointModel(url: url,
                                token: MainUserSession.GetToken(),
                                tokenSecondaryUser: SecondaryUserSession.GetUser()?.token,
                                method: "PUT",
                                query: query,
                                body: newValue)
        
        
        BLServerManager.ApiCall(endpoint: request) { response in
            DispatchQueue.main.async {
        
                self.singleLabelTableView.items.removeAll()
                self.loadData()
            }
        } fail: { (error) in
            DispatchQueue.main.async {
                self.singleLabelTableView.showItems()
            }
        }
    }
}

extension SettingsGeneralViewController: GenericTableViewDelegate {
    func selectedRow(row: Int) {
        print("selected row : \(row)")
    }
    
    func textFieldDidChanged(row: Int, columnIdentifier: String, stringValue: String) {
        guard
            let columIndex = input.info.column.columns.firstIndex(where: {$0.fieldName == columnIdentifier}),
            let type = input.info.column.columns[columIndex].type,
            let castedValue = castValue(type: type, stringValue: stringValue)
        else {
            singleLabelTableView.showItems()
            return
        }
        
        singleLabelTableView.tableView.deselectAll(nil)
        let index = IndexSet(integer: row)
        singleLabelTableView.tableView.selectRowIndexes(index, byExtendingSelection: true)
   
        var newValue = singleLabelTableView.items[row]
        newValue.updateValue(castedValue, forKey: columnIdentifier)
        updateData(newValue: newValue, row: row)
    }
    
    private func castValue(type: String, stringValue: String) -> Any? {
        var castedValue: Any?
           
        switch type {
        case GenericTableViewColumnModel.ColumnType.string.rawValue, GenericTableViewColumnModel.ColumnType.popup_secondary_user.rawValue:
            castedValue = String(stringValue)
            break
        case GenericTableViewColumnModel.ColumnType.bool.rawValue, GenericTableViewColumnModel.ColumnType.popup_bool.rawValue:
            if let boolValue = Bool(stringValue) {
                castedValue =  boolValue
            }
            break
        case GenericTableViewColumnModel.ColumnType.double.rawValue:
            if let doubleValue = Double(stringValue) {
                castedValue = doubleValue
            }
            break
        case GenericTableViewColumnModel.ColumnType.int.rawValue:
            if let intValue = Int(stringValue) {
                castedValue = intValue
            }
            break
        case GenericTableViewColumnModel.ColumnType.date.rawValue:
            
            if let dateValue = stringValue.toDate(formato: "dd-MM-yyyy HH:mm:ss")?.timeIntervalSince1970 {
                castedValue = Double(dateValue)
            } else
            if let dateValue = stringValue.toDate(formato: "dd-MM-yyyy")?.timeIntervalSince1970 {
                castedValue = Double(dateValue)
            }
            break
        default: break
            
        }
        
        return castedValue
    }
    
}

struct SettingModel: Codable {
    var type: String
    var viewcontroller: [ViewControllerModel]
    
    struct ViewControllerModel: Codable {
        var type: GenericTableViewColumnModel.ViewcontrollerType
        var title: String
        var backgroundColor: String
        var column: GenericTableViewColumnModel
        var request: GenericTableViewColumnModel.RequestData?
    }
    
    
}
