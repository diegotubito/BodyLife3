//
//  Constants.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 09/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation
import Cocoa

struct ImageSize {
    static let thumbnail = 40
    static let storageSize = 100
}

struct Constants {
// MARK : USER DEFAULTS KEYS
    enum UserDefaultKey : String {
        case user_session = "user session"
    }
// MARK : DATE CONSTANTS
    struct DateConstants {
        static let MonthName = [1:"Enero".localized, 2:"Febrero".localized, 3:"Marzo".localized, 4:"Abril".localized, 5:"Mayo".localized, 6:"Junio".localized, 7:"Julio".localized, 8:"Agosto".localized, 9:"Septiembre".localized, 10:"Octubre".localized, 11:"Noviembre".localized, 12:"Diciembre".localized]
        
        static let DayName = ["Domingo".localized,
        "Lunes".localized,
        "Martes".localized,
        "Miércoles".localized,
        "Jueves".localized,
        "Viernes".localized,
        "Sábado".localized]

    }
    
// MARK: BORDERS
    struct Borders {
        struct CustomerList {
            static let color = Colors.Gray.gray28.cgColor
            static let width : CGFloat = 1
        }
        struct Status {
            static let color = Colors.Gray.gray28.cgColor
            static let width : CGFloat = 1
        }
        struct RegisterList {
            static let color = Colors.Gray.gray28.cgColor
            static let width : CGFloat = 1
        }
        struct SellActivity {
            static let color = Colors.Gray.gray28.cgColor
            static let width: CGFloat = 1
        }
    }
    
// MARK: VIEWCONTROLLER SIZES
    
    struct ViewControllerSizes {
        struct Home {
            static let width : CGFloat = 0.8
            static let height : CGFloat = 0.7
        }
        struct Login {
            static let width : CGFloat = 0.35
            static let height : CGFloat = 0.4
        }
    }

// MARK: COLORS
    struct Colors {
        struct BodyLife {
            static let woman = NSColor(hex: 0xD096D1)
            static let man = NSColor(hex: 0x2730D1)
        }
        
        struct Green {
            static let fern = NSColor(hex: 0x6ABB72)
            static let mountainMeadow = NSColor(hex: 0x3ABB9D)
            static let chateauGreen = NSColor(hex: 0x4DA664)
            static let persianGreen = NSColor(hex: 0x2CA786)
        }
        
        struct Blue {
            static let pictonBlue = NSColor(hex: 0x5CADCF)
            static let mariner = NSColor(hex: 0x3585C5)
            static let curiousBlue = NSColor(hex: 0x4590B6)
            static let denim = NSColor(hex: 0x2F6CAD)
            static let chambray = NSColor(hex: 0x485675)
            static let blueWhale = NSColor(hex: 0x29334D)
            static let sponge = NSColor(hex: 0x5D92B1)
            static let saturatedBlue = NSColor(hex: 0x739AC5)
        }
        
        struct Violet {
            static let wisteria = NSColor(hex: 0x9069B5)
            static let blueGem = NSColor(hex: 0x533D7F)
        }
        
        struct Yellow {
            static let energy = NSColor(hex: 0xF2D46F)
            static let turbo = NSColor(hex: 0xF7C23E)
            
        }
        
        struct Orange {
            static let neonCarrot = NSColor(hex: 0xF79E3D)
            static let sun = NSColor(hex: 0xEE7841)
            static let carrot = NSColor(hex: 0xED9121)
        }
        
        struct Red {
            static let terraCotta = NSColor(hex: 0xE66B5B)
            static let valencia = NSColor(hex: 0xCC4846)
            static let cinnabar = NSColor(hex: 0xDC5047)
            static let wellRead = NSColor(hex: 0xB33234)
            static let ematita = NSColor(hex: 0xE35152)
            static let cramberry_jello = NSColor(hex: 0xF54D70)
            static let madderlakedeep  = NSColor(hex: 0xE32E30)
            
            
        }
        
        struct Gray {
            static let almondFrost = NSColor(hex: 0xA28F85)
            static let whiteSmoke = NSColor(hex: 0xEFEFEF)
            static let iron = NSColor(hex: 0xD1D5D8)
            static let ironGray = NSColor(hex: 0x75706B)
            
            static let gray28 = NSColor(hex: 0x474747)
            static let gray21 = NSColor(hex: 0x363636)
            static let gray17 = NSColor(hex: 0x2B2B2B)
            static let gray11 = NSColor(hex: 0x1C1C1C)
            static let gray10 = NSColor(hex: 0x171717)
            static let gray13 = NSColor(hex: 0x1E1E1E)
                          
            
        }
    }
    
//    MARK: MAX
    struct Max {
        static let inputAmountNumber : Double = 999999
    }
    
}
