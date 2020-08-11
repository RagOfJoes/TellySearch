//
//  Credits.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/5/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct Credits: Codable {
    let id: Int
    let cast: [Cast]?
    let crew: [Crew]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cast
        case crew
    }
}
