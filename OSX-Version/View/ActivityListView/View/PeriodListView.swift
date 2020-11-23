//
//  ActivityListView.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 07/02/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Cocoa

class PeriodListView : GenericCollectionView<PeriodListItem, PeriodModel.Populated> {
    
    var viewModel : PeriodListViewModelContract!
    
    var didSelectPeriod : ((PeriodModel.Populated?) -> Void)?
    
    override func commonInit() {
        super .commonInit()
        
        viewModel = PeriodListViewModel(withView: self)
        
        onSelectedItem = { (item) in
            self.didSelectPeriod?(item)
        }
        
        
    }
    
    override func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        return NSSize(width: (self.frame.width - (3 * 10)) / 3, height: 50)
    }
    
}

extension PeriodListView : PeriodListViewContract {
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
