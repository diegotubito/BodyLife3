//
//  GeneralPurpose.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 14/03/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

extension CommonWorker {
    struct GeneralPurpose {
        static func readLocalFile(bundle: Bundle, forName name: String) -> Data? {
            guard
                let bundlePath = bundle.path(forResource: name, ofType: "json"),
                let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8)
            else { return nil }
            
            return jsonData
        }
    }
}
