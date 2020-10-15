//
//  Crew.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct Crew: Codable {
    let id: Int
    let job: String
    let name: String
    let department: String
    let profilePath: String?
    var cacheKey: String {
        get {
            return "crew:\(id):detail"
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case job
        case name
        case department
        case profilePath = "profile_path"
    }
}
