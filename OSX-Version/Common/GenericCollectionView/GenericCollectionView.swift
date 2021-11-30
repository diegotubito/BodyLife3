//
//  GenericCollectionView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 23/12/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Cocoa

class GenericCollectionItem<U>: NSCollectionViewItem {
    var item : U!
    var selectionBackgroundColor = NSColor.green
    var selectionBorderColor = NSColor.green
    var selectionBorderWidth : CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.borderWidth = 0
        view.layer?.borderColor = NSColor.red.cgColor
        view.layer?.cornerRadius = 15
    }
    static var identifier : String {
        return String(describing: self)
    }
    
    static var nib: NSNib? {
        return NSNib(nibNamed: identifier, bundle: nil)
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? selectionBorderWidth : 0.0
        view.layer?.borderColor = selected ? selectionBorderColor.cgColor : NSColor.clear.cgColor
        view.layer?.backgroundColor = selected ? selectionBackgroundColor.cgColor : NSColor.clear.cgColor
    }
}

class GenericCollectionView<T: GenericCollectionItem<U>, U>: XibView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    var scrollView : NSScrollView!
    var collectionView : NSCollectionView!
    var layout : NSCollectionViewFlowLayout!
    var numberOfVisibleItems = 6
    var minimumLineSpacing : CGFloat = 10
    var minimumInteritemSpacing : CGFloat = 10
    
    var items : [U] = []
    var onSelectedItem : ((U) -> ())?
    
    override func commonInit() {
        super .commonInit()
        
        createScrollView()
    }
    
    func createScrollView() {
        createCollection()
      
        scrollView = NSScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        scrollView.documentView = collectionView
        self.addSubview(scrollView)
        
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            scrollView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            scrollView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    private func createCollection() {
        layout = NSCollectionViewFlowLayout()
        layout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        
        collectionView = NSCollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        collectionView.wantsLayer = true
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.collectionViewLayout = layout
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        return NSSize(width: self.frame.width, height: self.frame.height/CGFloat(numberOfVisibleItems))
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: T.identifier), for: indexPath) as? GenericCollectionItem<U> {
            cell.item = items[indexPath.item]
            
            if let selectedIndexPath = collectionView.selectionIndexPaths.first, selectedIndexPath == indexPath {
                cell.setHighlight(selected: true)
            } else {
                cell.setHighlight(selected: false)
            }
            
            return cell
        }
        return NSCollectionViewItem()
        
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {return}
        
        collectionView.reloadData()
        guard let item = collectionView.item(at: indexPath) else {
            return
        }
        
        (item as! GenericCollectionItem<U>).setHighlight(selected: true)
        onSelectedItem?(items[indexPath.item])
        
    }
}


