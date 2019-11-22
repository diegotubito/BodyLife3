//
//  NSViewExtension.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 20/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

extension NSView {
    func Blur() {
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setDefaults()
        blurFilter?.setValue(5.0, forKey: kCIInputRadiusKey)
        self.layer?.backgroundFilters?.append(blurFilter!)
    }
}
