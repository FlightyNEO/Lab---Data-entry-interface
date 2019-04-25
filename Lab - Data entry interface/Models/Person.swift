//
//  Person.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 23/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import Foundation

struct Person {
    
    init() {
        firstName = ""
        lastName = ""
        eMail = ""
    }
    
    var firstName: String
    var lastName: String
    var eMail: String
    
}

extension Person {
    
    var fulName: String {
        return firstName + " " + lastName
    }
    
}
