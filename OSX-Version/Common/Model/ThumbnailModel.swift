//
//  ThumbnailModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 29/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation


class ThumbnailModel {
    struct Thumbnail : Decodable {
        var _id : String
        var thumbnailImage : String
        var isEnabled : Bool
    }
}

