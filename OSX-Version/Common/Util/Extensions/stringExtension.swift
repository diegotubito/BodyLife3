//
//  stringExtension.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa


extension String {
    var convertToImage: NSImage? {
        let decodedData = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0) )
        
        let decodedimage = NSImage(data: decodedData! as Data)
        
        return decodedimage
        
    }
    
    func toDate(formato: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formato
        
        let dateNSDate = dateFormatter.date(from: self)
        
        return dateNSDate
    }
}

extension String {
    
    static func random(length: Int = 12) -> String {
        let base = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

extension String {
    func height(constraintedWidth width: CGFloat, font: NSFont) -> CGFloat {
        let label =  NSTextView(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.string = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
}



extension StringProtocol {
    var ascii: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}

extension Character {
    var ascii: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

extension String {
    var localized: String {
        //🖕Fuck the translators team, they don’t deserve comments
        return NSLocalizedString(self, comment: "")
    }
}

extension String {
    func hexToFloat() -> UInt32 {
        let result = UInt32(strtoul(self, nil, 16))  // 255
        return result
    }
}
