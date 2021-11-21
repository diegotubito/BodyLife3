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
    var popup: NSPopUpButton!
    
    struct PopupTitles {
        enum SecondaryUserRole: String, CaseIterable {
            case superRole = "SUPER_ROLE"
            case adminRole = "ADMIN_ROLE"
            case commonRole = "USER_ROLE"
        }
        
        enum Bool: String, CaseIterable {
            case enable = "true"
            case disable = "false"
        }
    }
  
    override var item: [String: Any]? {
        didSet {
            guard let item = item,
                  let fieldName = column.fieldName
            else { return }
            
            if isPopUp() {
                let title = getTitle(dictionary: item, fieldName: fieldName)
                let popupItemTitles = getPopupTitle()
                popup.addItems(withTitles: popupItemTitles)
                popup.selectItem(withTitle: title)
                popup.isHidden = false
                singleLabel.isHidden = true
            } else {
                popup.isHidden = true
                singleLabel.isHidden = false
                singleLabel.stringValue = getTitle(dictionary: item, fieldName: fieldName)
                singleLabel.delegate = self
                setStatus(label: singleLabel)
            }
            
            if let isEnabled = item["isEnabled"] as? Bool, !isEnabled {
                singleLabel.textColor = .darkGray
            }

        }
    }
    
    override func commonInit() {
        addTitle()
        addPopUpButton()
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
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        valueMustBeUpdatedDataBase(value: fieldEditor.string)
        return true
    }
    
    private func valueMustBeUpdatedDataBase(value: String) {
        let stringValue = value
        textFieldDidChanged(columnIdentifier: column.fieldName ?? "", stringValue: stringValue)
    }
}


// MARK: NSPopup Button

extension SingleLabelTableViewItem {
    private func addPopUpButton() {
        popup = NSPopUpButton(checkboxWithTitle: "prueba", target: self, action: #selector(discountPopupDidChanged(_:)))
        popup.frame = self.frame
        
        addSubview(popup)
    }
    
    @objc func discountPopupDidChanged(_ sender: NSPopUpButton) {
        let value = getPopupTitle()[sender.indexOfSelectedItem]
        valueMustBeUpdatedDataBase(value: value)
    }
    
    private func getPopupTitle() -> [String] {
        let type = getType()
        switch type {
        case GenericTableViewColumnModel.ColumnType.popup_secondary_user.rawValue:
            return PopupTitles.SecondaryUserRole.allCases.map { $0.rawValue }
        case GenericTableViewColumnModel.ColumnType.popup_bool.rawValue:
            return PopupTitles.Bool.allCases.map { $0.rawValue }
        default:
            return []
        }
        
    }
}

// MARK: Constraints

extension SingleLabelTableViewItem {
    private func addContraints() {
        singleLabel.translatesAutoresizingMaskIntoConstraints = false
        singleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        singleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        singleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        popup.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        popup.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        popup.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
    }
}
