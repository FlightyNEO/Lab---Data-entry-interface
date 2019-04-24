//
//  Registration.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 23/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import Foundation

struct Registration {
    
    init() {
        owner = Person()
        checkInDate = Date(timeIntervalSince1970: 0)
        checkOutDate = Date()
    }
    
    /* Guests info */
    var owner: Person
    
    /* Date */
    var checkInDate: Date
    var checkOutDate: Date
    
    /* Guests */
    var numberOfAdults = 1
    var numberOfChildren = 0
    
    /* Wi-Fi */
    var wifiEnable = false
    
    /* Room */
    var room: RoomType?
    
}

extension Registration: Comparable {
    
    static func == (lhs: Registration, rhs: Registration) -> Bool {
        return
            lhs.checkInDate.timeIntervalSince1970 == rhs.checkInDate.timeIntervalSince1970 &&
            lhs.checkOutDate.timeIntervalSince1970 == rhs.checkOutDate.timeIntervalSince1970
    }
    
    static func < (lhs: Registration, rhs: Registration) -> Bool {
        if lhs.checkInDate.timeIntervalSince1970 == rhs.checkInDate.timeIntervalSince1970 {
            return lhs.checkOutDate.timeIntervalSince1970 < rhs.checkOutDate.timeIntervalSince1970
        }
        
        return lhs.checkInDate.timeIntervalSince1970 < rhs.checkInDate.timeIntervalSince1970
        
    }
    
}
