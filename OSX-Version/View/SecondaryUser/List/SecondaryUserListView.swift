//
//  SecondaryUserListView.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 10/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation
import BLServerManager

class SecondaryUserListView : GenericCollectionView<SecondaryUserItem, SecondaryUserSessionModel> {
    override func commonInit() {
        super .commonInit()
        
    }
    
    private func loadUsers() {
        let endpoint = Endpoint.Create(to: .SecondaryUser(.Load))
        BLServerManager.ApiCall(endpoint: endpoint) { (response : ResponseModel<[SecondaryUserSessionModel]>) in
            guard let users = response.data else {
                return
            }
            self.items = users
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } fail: { (error) in
            print(error)
        }

    }
}
