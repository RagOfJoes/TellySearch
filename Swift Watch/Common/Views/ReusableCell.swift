//
//  ReusableCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

public protocol ReusableCell {    
    static var reuseIdentifier: String { get }
}

// Default to using ClassName as the ReuseIdentifier
public extension ReusableCell {
    static var reuseIdentifier: String {
        get {
            return String(describing: self)
        }
    }
}
