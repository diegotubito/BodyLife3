//
//  ConfigModel.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 04/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

struct ConfigModel : Decodable {
    var account : AccountModel

    struct AccountModel : Decodable {
        var disabled : Bool
    }

}

