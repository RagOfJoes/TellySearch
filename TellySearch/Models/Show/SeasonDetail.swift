//
//  SeasonDetail.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct SeasonDetail: Codable {
    let credits: Credits?
    let episodes: [Episode]?
    
    enum CodingKeys: String, CodingKey {
        case credits
        case episodes
    }
}
