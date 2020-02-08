//
//  ActivityListView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class ActivityListView : GenericCollectionView<ActivityListItem, ActivityModel> {
    
    var viewModel : ActivityListViewModelContract!
    
    var didSelectActivity : ((ActivityModel?) -> Void)?
    
    override func commonInit() {
        super .commonInit()
        
        viewModel = ActivityListViewModel(withView: self)
        
        onSelectedItem = { (item) in
            self.didSelectActivity?(item)
        }
    }
    
    override func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
           return NSSize(width: 100, height: 100)
    }
    
}

extension ActivityListView : ActivityListViewContract {
    func displayList() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func showError() {
        
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
}
