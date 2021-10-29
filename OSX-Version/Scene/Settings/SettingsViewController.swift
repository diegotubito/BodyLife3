//
//  CrudViewController.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 27/02/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class SettingsViewController : NSTabViewController {
    
    struct Constants {
        static let imageName: String = ""
        static let defaultTitle = "_no_title"
        static let defaultProportional: CGFloat = 0.1
        
        struct Parameters {
            static let width = "width"
            static let height = "height"
            static let viewControllers = "viewControllers"
            static let title = "title"
            static let imageName = "imageName"
        }
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        let tabbarInfo = loadDataFromJsonFile()
        setupTabViewController(dictionary: tabbarInfo)
        setupViewControllers(dictionary: tabbarInfo)
    }
    
 
    func loadDataFromJsonFile() -> [String: Any] {
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: Bundle(for: SettingsViewController.self), forName: "Settings"),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return [:] }
        
        return dictionary
    }
    
    func loadViewControllersFromJsonFile(name: String) -> [[String: Any]] {
        guard
            let data = CommonWorker.GeneralPurpose.readLocalFile(bundle: Bundle(for: SettingsViewController.self), forName: name),
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        else { return [] }
        
        return dictionary
    }
    
    private func setupTabViewController(dictionary: [String: Any]) {
        let widthProportional = dictionary[Constants.Parameters.width] as? CGFloat ?? Constants.defaultProportional
        let heightProportional = dictionary[Constants.Parameters.height] as? CGFloat ?? Constants.defaultProportional
        let width = (NSScreen.main?.frame.size.width ?? 0.0) * widthProportional
        let height = (NSScreen.main?.frame.size.height ?? 0.0) * heightProportional
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        //si queremos usar icons en el tabviewcontroller, tabStyle debe ser .toolBar
        tabStyle = .toolbar
    }
    
    
    private func setupViewControllers(dictionary: [String: Any]) {
        let viewcontrollers = dictionary[Constants.Parameters.viewControllers] as? [[String: Any]] ?? []
        viewcontrollers.forEach({ vc in
            //creamos un viewcontroller de forma programatica
            let generalViewController = SettingsGeneralViewController()
            
            guard
                let vcData = try? JSONSerialization.data(withJSONObject: vc, options: []),
                let info = try? JSONDecoder().decode(SettingModel.ViewControllerModel.self, from: vcData) else { return }
            
            generalViewController.input = SettingsGeneralViewController.Input(info: info)
            generalViewController.title = ((vc[Constants.Parameters.title] as? String) ?? Constants.defaultTitle).localized
            let imageName = vc[Constants.Parameters.imageName] as? String ?? Constants.imageName
            let image = NSImage(named: imageName)
            let newItem = NSTabViewItem(viewController: generalViewController)
            newItem.image = image
            addTabViewItem(newItem)
        })
    }
}
