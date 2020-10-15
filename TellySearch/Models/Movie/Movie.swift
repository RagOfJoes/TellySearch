//
//  Movie.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct MovieFetchError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "MovieFetchError", description: String) {
        self.title = title
        self.description = description
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let backdropPath: String?
    var cacheKey: String {
        get {
            return "movie:\(id):detail"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
    }
}
