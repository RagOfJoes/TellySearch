//
//  Show.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/3/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct ShowFetchError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "ShowFetchError", description: String) {
        self.title = title
        self.description = description
    }
}

struct Show: Codable {    
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String
    let backdropPath: String?
    var cacheKey: String {
        get {
            return "show:\(id):detail"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
    }
}
