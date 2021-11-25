//
//  CommonRouter.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 15/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

protocol CommonRouterProtocol {
    func routeToSecondaryLogin(vc: NSViewController)
}

extension CommonRouterProtocol {
    
    func routeToSecondaryLogin(vc: NSViewController) {
        let storyboard = NSStoryboard(name: "SecondaryUser", bundle: nil)
        let destinationVC = storyboard.instantiateController(withIdentifier: "SecondaryUserLoginViewController") as! SecondaryUserLoginViewController
        destinationVC.delegate = vc as? SecondaryUserLoginDelegate
        vc.presentAsSheet(destinationVC)
    }
}
