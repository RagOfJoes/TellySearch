//
//  Movie.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct Movie: Codable, Hashable {
    let id: Int
    let runtime: Int?
    let title: String
    let genres: [Genre]
    let rateAvg: Double
    let tagline: String?
    let overview: String?
    let releaseDate: Date
    let posterPath: String?
    let backdropPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case genres
        case tagline
        case runtime
        case overview
        case rateAvg = "vote_avg"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
    }
}
