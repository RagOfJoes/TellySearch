//
//  Array+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/8/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

extension Array {
    /// Generates an Array that contains unique Values based on the KeyPath parameter passed.
    ///
    /// ```
    /// let dummyArray: [Movie] = [{ id: 1 }, { id: 2 }, { id: 1 }, { id: 3 }]
    /// let uniqueArray = dummyArray.unique(on: \Movie.id) // Will generate [{ id: 1 }, { id: 2 }, { id: 3 }]
    /// ```
    ///
    /// - Parameter property: The KeyPath that will determine whtat is and isn't unique
    func unique<T:Hashable>(on property: KeyPath<Element, T>)  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(value[keyPath: property]) {
                set.insert(value[keyPath: property])
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
