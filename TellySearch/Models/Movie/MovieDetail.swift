//
//  MovieDetail.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct MovieDetail: Codable {
    let runtime: Int?
    let rateAvg: Double
    let genres: [Genre]?
    let tagline: String?
    let credits: Credits
    let recommendations: MovieSection?
    
    var directors: [Crew]? {
        get {
            let directors = credits.crew?.filter({ (crew) -> Bool in
                return crew.job == "Director"
            })
            
            return directors
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case genres
        case tagline
        case runtime
        case credits
        case recommendations
        case rateAvg = "vote_average"
    }
}
