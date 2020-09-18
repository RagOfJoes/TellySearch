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
    
    struct Poster {
        static let URL = "https://image.tmdb.org/t/p/w300"
        static let ratio: CGFloat = (27/40)
        static var minWidth: CGFloat {
            get {
                let screen = UIScreen.main.bounds
                if screen.width > 500 {
                    return screen.width / 6.25
                } else {
                    return screen.width / 3
                }
            }
        }
        static var width: CGFloat {
            get {
                let numberOfCells: CGFloat = UIScreen.main.bounds.width / minWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * minWidth)
                
                return width
            }
        }
        static var height: CGFloat {
            get {
                return .getHeight(with: width, using: ratio)
            }
        }
    }
    
    struct Overview {
        enum CellType {
            case regular
            case featured
        }
        
        static var regularHeight: CGFloat {
            get {
                let placeholder = "Lorem"
                let primaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
                
                let primaryHeight = placeholder.height(font: primaryFont) * 2
                
                return primaryHeight + K.Poster.height + 5
            }
        }
        static var regularHeightWithSecondary: CGFloat {
            get {
                let placeholder = "Lorem"
                let primaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
                let secondaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
                
                let primaryHeight = placeholder.height(font: primaryFont) * 2
                let secondaryHeight = placeholder.height(font: secondaryFont)
                
                return primaryHeight + secondaryHeight + K.Poster.height + 5
            }
        }
        
        static let featuredImageRatio: CGFloat = (16/9)
        static var featuredMinWidth: CGFloat {
            get {
                let screen = UIScreen.main.bounds
                if screen.width > 500 {
                    return screen.width / 2
                } else {
                    return screen.width
                }
            }
        }
        static var featuredCellWidth: CGFloat {
            get {
                let numberOfCells: CGFloat = UIScreen.main.bounds.width / featuredMinWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * featuredMinWidth)
                
                return width - 40
            }
        }
    }
    
    struct Backdrop {
        static let heightConstant: CGFloat = 400
        static let URL = "https://image.tmdb.org/t/p/original"
    }
    
    struct Credits {
        static let profileURL = "https://image.tmdb.org/t/p/w200"
        static let baseURL = "https://api.themoviedb.org/3/person"
    }
}
