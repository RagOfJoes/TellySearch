//
//  Constants.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct K: Codable {
    static let tmdbApiKey: String = {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let obj = NSDictionary(contentsOfFile: path)
            
            if let apiKey = obj?["tmdbApiKey"] as? String {
                return apiKey
            }
            
            fatalError("Must provide a valid tmdbApiKey!")
        }
        
        return ""
    }()
}
