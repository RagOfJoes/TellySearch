//
//  MovieFetchType.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum MovieFetchType: String {
    case detail
    case popular = "popular"
    case upcoming = "upcoming"
    case topRated = "top_rated"
    case inTheatres = "now_playing"
}
