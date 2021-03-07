//
//  MainOptionsViewCell.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 07/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Cocoa

//class MainOptionsViewCell: GenericCollectionItem {
//    var titleLabel : NSTextField!
//    
//    var item : MainOptionModel.Item? {
//        didSet {
//            guard let item = item else { return }
//            titleLabel.stringValue = item.title ?? ""
//        }
//    }
//    
//    override init(frame frameRect: NSRect) {
//        super .init(frame: frameRect)
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("xib file not implemented")
//    }
//    
//    private func commonInit() {
//        addTitle()
//        addContraints()
//    }
//    
//    private func addTitle() {
//        titleLabel = NSTextField(frame: CGRect.zero)
//        titleLabel.lineBreakMode = .byTruncatingTail
//        titleLabel.maximumNumberOfLines = 0
//        self.addSubview(titleLabel)
//    }
//    
//    private func addContraints() {
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
//        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
//        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:0).isActive = true
//    }
//}
