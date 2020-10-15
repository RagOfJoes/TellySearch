//
//  Constants.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

struct K {
    static let ScrollOffsetHeight: CGFloat = 45
    static let CommonQuery: String = "?api_key=\(K.TmdbApiKey)&region=\(K.User.country)&language=\(K.User.language)"
    static let TmdbApiKey: String = {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let obj = NSDictionary(contentsOfFile: path)
            
            if let apiKey = obj?["tmdbApiKey"] as? String {
                return apiKey
            }
            
            fatalError("Must provide a valid tmdbApiKey!")
        }
        
        return ""
    }()
    
    struct User {
        static let country: String = Locale.current.regionCode ?? "US"
        static let language: String = Locale.current.languageCode ?? "en"
        static let timezone: String = TimeZone.current.abbreviation() ?? "EST"
    }
    
    struct URL {
        // Images
        static let Poster: String = "https://image.tmdb.org/t/p/w500"
        static let Backdrop: String = "https://image.tmdb.org/t/p/original"
        
        // Data
        static let Show: String = "https://api.themoviedb.org/3/tv"
        static let Movie: String = "https://api.themoviedb.org/3/movie"
        static let Credits: String = "https://api.themoviedb.org/3/person"
    }
}
