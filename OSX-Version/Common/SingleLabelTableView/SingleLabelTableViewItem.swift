//
//  MainOptionsViewCell.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class SingleLabelTableViewItem: GenericTableViewItem, NSTextFieldDelegate {
    var myLabel : NSTextField!
  
    override var item: [String: Any]? {
        didSet {
            guard let item = item,
                  let fieldName = column.fieldName
            else { return }
            if let isEnabled = item["isEnabled"] as? Bool, !isEnabled {
                myLabel.textColor = .darkGray
            }
            myLabel.stringValue = getTitle(dictionary: item, fieldName: fieldName)
            myLabel.delegate = self
            setStatus(label: myLabel)
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
        myLabel.wantsLayer = true
        myLabel.backgroundColor = .clear
        myLabel.isBezeled = false
        self.addSubview(myLabel)
    }
    
    private func addContraints() {
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        myLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        myLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        myLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let stringValue = fieldEditor.string
        textFieldDidChanged(columnIdentifier: column.name ?? "", stringValue: stringValue)
        return true
    }
}
