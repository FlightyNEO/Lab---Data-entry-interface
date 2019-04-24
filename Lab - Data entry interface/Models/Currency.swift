//
//  Currency.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 24/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import Foundation

enum Currency: String {
    
    case USD, EUR, RUB
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .RUB: return "₽"
            //case Coin(let sym): return sym
        }
    }
    
    var locale: Locale {
        
        let locale: Locale
        
        switch self {
        case .USD: locale = Locale(identifier: "ru_US")
        case .EUR: locale = Locale(identifier: "ru_ES")
        case .RUB: locale = Locale(identifier: "ru_RU")
        }
        
        return locale
        
    }
    
}
