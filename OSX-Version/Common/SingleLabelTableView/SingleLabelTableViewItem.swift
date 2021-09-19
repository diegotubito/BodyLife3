//
//  MainOptionsViewCell.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

class SingleLabelTableViewItem: GenericTableViewItem, NSTextFieldDelegate {
    var singleLabel : NSTextField!
  
    override var item: [String: Any]? {
        didSet {
            guard let item = item,
                  let fieldName = column.fieldName
            else { return }
            
            if let isEnabled = item["isEnabled"] as? Bool, !isEnabled {
                singleLabel.textColor = .darkGray
            }
            singleLabel.stringValue = getTitle(dictionary: item, fieldName: fieldName)
            singleLabel.delegate = self
            setStatus(label: singleLabel)
        }
    }
    
    override func commonInit() {
        addTitle()
        addContraints()
    }
    
    private func addTitle() {
        singleLabel = NSTextField(frame: CGRect.zero)
        singleLabel.lineBreakMode = .byTruncatingTail
        singleLabel.maximumNumberOfLines = 0
        singleLabel.wantsLayer = true
        singleLabel.backgroundColor = .clear
        singleLabel.isBezeled = false
        self.addSubview(singleLabel)
    }
    
    private func addContraints() {
        singleLabel.translatesAutoresizingMaskIntoConstraints = false
        singleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        singleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        singleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let stringValue = fieldEditor.string
        textFieldDidChanged(columnIdentifier: column.name ?? "", stringValue: stringValue)
        return true
    }
}
