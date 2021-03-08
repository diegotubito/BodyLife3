//
//  MainOptionsViewCell.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class MainOptionsViewCell: GenericTableViewItem<MainOptionModel.Item> {
    var myLabel : NSTextField!
    
    override var item: MainOptionModel.Item? {
        didSet {
            myLabel.stringValue = getTitle()
        }
    }
    
    override func commonInit() {
        addTitle()
        addContraints()
    }
    
    private func addTitle() {
        myLabel = NSTextField(frame: CGRect.zero)
        myLabel.lineBreakMode = .byTruncatingTail
        myLabel.maximumNumberOfLines = 0
        myLabel.textColor = .red
        self.addSubview(myLabel)
    }
    
    private func addContraints() {
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        myLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        myLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        myLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
    }
}
