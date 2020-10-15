//
//  Credits.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/5/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct CreditFetchError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "CreditFetchError", description: String) {
        self.title = title
        self.description = description
    }
}

struct Credits: Codable {
    let id: Int?
    let cast: [Cast]?
    let crew: [Crew]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case cast
        case crew
    }
}
