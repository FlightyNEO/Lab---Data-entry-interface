//
//  IndexPath+Extension.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 23/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

import UIKit

extension IndexPath {
    var prevRow: IndexPath {
        let row = self.row - 1
        let section = self.section
        
        return IndexPath(row: row, section: section)
    }
}
