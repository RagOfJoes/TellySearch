//
//  FetchTypes.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum FetchTypes: String {
    case popular = "popular"
    case trending = "trending"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case inTheatres = "now_playing"
    
    case onTheAir = "on_the_air"
    case onTheAirToday = "airing_today"
}
