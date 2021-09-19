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
        let jsonInfo: [String: Any]
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
        let color = input.jsonInfo[Constants.Parameters.backgroundColor] as? String ?? Constants.defaultBackgroundColor
        view.layer?.backgroundColor = NSColor(hexString: color).cgColor
        
       // loadItems()
        loadCarnets()
    }
    
    private func drawCustomTableView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let column = input.jsonInfo["column"] as! [String: Any]
        singleLabelTableView = SingleLabelTableView(frame: frame, columns: column)
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
    
    func loadCarnets() {
        let uid = MainUserSession.GetUID()
        let path = "product:article"
        
        let request = Endpoint.Create(to: .Period(.LoadAll))
        BLServerManager.ApiCall(endpoint: request) { (response:ResponseModel<[PeriodModel.Populated]>) in
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
