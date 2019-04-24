//
//  Array+Extension.swift
//  Lab - Data entry interface
//
//  Created by Arkadiy Grigoryanc on 24/04/2019.
//  Copyright © 2019 Arkadiy Grigoryanc. All rights reserved.
//

extension Array {
    
    func insertionIndexOf(_ element: Element, _ isOrderedBefore: (Element, Element) -> Bool) -> Int {
        
        var lo = 0
        var hi = count - 1
        
        while lo <= hi {
            let mid = (lo + hi) / 2
            
            if isOrderedBefore(self[mid], element) {
                lo = mid + 1
            } else if isOrderedBefore(element, self[mid]) {
                hi = mid - 1
            } else {
                return mid
            }
        }
        
        return lo
    }
    
}
