//
//  ShowSection.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct ShowSection: Codable {    
    // Section Title
    let title: String?
    let results: [Show]?
    
    init(title: String, results: [Show]? = nil) {
        self.title = title
        self.results = results
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case results
    }
}
