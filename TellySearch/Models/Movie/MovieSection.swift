//
//  Movies.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

// MARK: - MovieSection
struct MovieSection: Codable {    
    // Section Title
    let title: String?
    let results: [Movie]?
    
    init(title: String, results: [Movie]? = nil) {
        self.title = title
        self.results = results
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case results
    }
}
