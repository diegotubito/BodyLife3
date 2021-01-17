//
//  IntExtension.swift
//  BodyLife3
//
//  Created by David Diego Gomez on 15/01/2021.
//  Copyright © 2021 David Diego Gomez. All rights reserved.
//

import Foundation

extension Int {
    func secondsToHoursMinutesSeconds() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = (self % 3600) % 60
        if hours > 0 {
            return ("\(hours)h \(minutes)m \(seconds)s")
        } else if minutes > 0 {
            return ("\(minutes)m \(seconds)s")
        } else if seconds > 0 {
            return ("\(seconds)s")
        } else {
            return ("expired")
        }
    }
}
