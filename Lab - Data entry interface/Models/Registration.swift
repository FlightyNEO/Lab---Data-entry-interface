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

// MARK: - Calcilate properties
extension Registration {
    
    private func calculateSum(_ price: Double, days: Int, multiply: Int = 1) -> Double {
        return price * Double(days) * Double(multiply)
    }
    
    var numberOfPerson: Int {
        return numberOfAdults + numberOfChildren
    }
    
    var numberOfDays: Int {
        return checkOutDate.days(from: checkInDate)
    }
    
    var roomTotalPrice: Double? {
        
        guard let room = room else { return nil }
            
        let price = Double(room.price)
        let counter = numberOfPerson / room.numberOfPlaces
        let multiply = counter + (numberOfPerson.isMultiple(of: room.numberOfPlaces) ? 0 : 1)
        return calculateSum(price, days: numberOfDays, multiply: multiply)
    }
    
    func wifiTotalPrice(_ price: Double) -> Double {
        
        let counter = numberOfPerson / Int(room?.numberOfPlaces ?? numberOfPerson)
        let multiply = counter + (numberOfPerson.isMultiple(of: room?.numberOfPlaces ?? 1) ? 0 : 1)
        
        return calculateSum(price, days: numberOfDays, multiply: multiply)
    }
    
}

// MARK: - Comparable
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

// MARK: - Sample load
extension Registration {
    
    init(firstName: String, lastName: String, checkInDate: Date, checkOutDate: Date) {
        self.init()
        self.owner.firstName = firstName
        self.owner.lastName = lastName
        self.owner.eMail = "test@test.com"
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.room = RoomType(id: 0, name: "Two Queens", shortName: "2Q", price: 179, numberOfPlaces: 2)
    }
    
    static func sampleLoad() -> [Registration] {
        
        return [
            Registration(firstName: "Аркадий", lastName: "Григорьянц", checkInDate: Date(), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 3)),
            Registration(firstName: "Ян", lastName: "Карлов", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 3), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 4)),
            Registration(firstName: "Дмитрий", lastName: "Козлов", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 3), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 6)),
            Registration(firstName: "Сергей", lastName: "Бойко", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 2), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 6)),
            Registration(firstName: "Иван", lastName: "Акулов", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 35), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 39)),
            Registration(firstName: "Илья", lastName: "Лансков", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 37), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 44)),
            Registration(firstName: "Алена", lastName: "Водонаева", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 75), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 79)),
            Registration(firstName: "Ирина", lastName: "Светлова", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 101), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 141)),
            Registration(firstName: "Юлия", lastName: "Денисова", checkInDate: Date().addingTimeInterval(60 * 60 * 24 * 356), checkOutDate: Date().addingTimeInterval(60 * 60 * 24 * 367)),
        ].sorted()
        
    }
    
}
