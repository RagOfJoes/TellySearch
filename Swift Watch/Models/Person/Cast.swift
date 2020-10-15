//
//  Cast.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Cache
import Promises
import Foundation

struct Cast: Codable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    var cacheKey: String {
        get {
            return "cast:\(id):detail"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}
