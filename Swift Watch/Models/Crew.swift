//
//  Crew.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct Crew: Codable, Hashable {
    let id: Int
    let job: String
    let name: String
    let department: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case job
        case name
        case department
        case profilePath = "profile_path"
    }
}
