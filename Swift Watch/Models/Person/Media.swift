//
//  Media.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum MediaType: String, Codable {
    case tv = "tv"
    case movie = "movie"
}

struct Media: Codable {
    let id: Int
    let name: String?
    let title: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let backdropPath: String?
    let mediaType: MediaType?
    
    // Cast
    let character: String?
    
    // Crew
    let job: String?
    let department: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case job
        case name
        case title
        case character
        case department
        case mediaType = "media_type"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
    }
}
