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
    
    func loadItems() {
        let uid = MainUserSession.GetUID()
        let path = "product:article"
        
        let endpoint = Endpoint.Create(to: .Article(.Load(userUID: uid, path: path)))
        
        BLServerManager.ApiCall(endpoint: endpoint) { (response: ResponseModel<[ArticleModel.NewRegister]>) in
            guard
                let data = response.data,
                let jsonArrayData = try? JSONEncoder().encode(data),
                let jsonArray = try? JSONSerialization.jsonObject(with: jsonArrayData, options: []) as? [[String: Any]]
            else { return }
            for key in jsonArray {
                print("\(key.keys)")
            }
            DispatchQueue.main.async {
                self.drawCustomTableView()
                self.singleLabelTableView.items = jsonArray
                self.singleLabelTableView.showItems()
            }
        } fail: { (error) in
            print("Could not load Articles", error)
            DispatchQueue.main.async {
                if self.singleLabelTableView != nil {
                    self.singleLabelTableView.removeFromSuperview()
                }
            }
        }
    }
    
    func loadData() {
        let uid = MainUserSession.GetUID()
        let path = input.info.request?.path ?? "need path"
        
        var finalPath = ""
        if let firebasePath = input.info.request?.firebasePath {
            finalPath = "\(BLServerManager.baseUrl.rawValue)\(firebasePath):\(uid):\(path)"
        } else {
            finalPath = "\(BLServerManager.baseUrl.rawValue)\(input.info.request?.path ?? "no path")"
        }
        let request = BLEndpointModel(url: finalPath,
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
}

extension SettingsGeneralViewController: GenericTableViewDelegate {
    func selectedRow(row: Int) {
        print("selected row : \(row)")
    }
    
    func textFieldDidChanged(columnIdentifier: String, stringValue: String) {
        print("ahora aca \(stringValue)")
        print(singleLabelTableView.tableView.selectedRow)
        print(singleLabelTableView.tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: columnIdentifier)))
        print(columnIdentifier)
    }
}


struct SettingModel: Codable {
    var type: String
    var viewcontroller: [ViewControllerModel]
    
    struct ViewControllerModel: Codable {
        var title: String
        var backgroundColor: String
        var column: Column
        var request: RequestData?
    }
    
    struct RequestData: Codable {
        var path: String
        var firebasePath: String?
        var method: String
        var query: String?
        var body: String?
    }
    
    struct Column: Codable {
        var rowHeight: Double
        var columns: [ColumnData]
        
        struct ColumnData: Codable {
            var name: String
            var isEditable: Bool
            var width: Double
            var fieldName: String
            var type: String
        }
    }
}
