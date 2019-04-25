//
//  Room.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 24/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

struct RoomType {
    var id: Int
    var name: String
    var shortName: String
    var price: Int
    var numberOfPerson: Int
    
    static var all: [RoomType] {
        return [
            RoomType(id: 0, name: "Two Queens", shortName: "2Q", price: 179, numberOfPerson: 2),
            RoomType(id: 1, name: "One King", shortName: "K", price: 209, numberOfPerson: 1),
            RoomType(id: 2, name: "Penthouse Suite", shortName: "PHS", price: 309, numberOfPerson: 4),
        ]
    }
}

// MARK: - Equatable
extension RoomType: Equatable {
    static func == (left: RoomType, right: RoomType) -> Bool {
        return left.id == right.id
    }
}
