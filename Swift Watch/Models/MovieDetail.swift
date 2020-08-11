//
//  MovieDetail.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct MovieDetail: Codable {
    let runtime: Int?
    let rateAvg: Double
    let genres: [Genre]?
    let tagline: String?
    
    enum CodingKeys: String, CodingKey {
        case genres
        case tagline
        case runtime
        case rateAvg = "vote_average"
    }
}
