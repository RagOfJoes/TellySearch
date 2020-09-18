//
//  Season.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct Season: Codable {
    let id: Int
    let name: String
    let airDate: String?
    let episodeCount: Int
    let seasonNumber: Int
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case posterPath = "poster_path"
        case episodeCount = "episode_count"
        case seasonNumber = "season_number"
    }
}
