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
        static let URL = "https://image.tmdb.org/t/p/w200"
        static var width: CGFloat {
            get {
                let screen = UIScreen.main.bounds
                let minWidth = screen.width > 500 ? screen.width / 6.25 : screen.width / 3
                
                let numberOfCells: CGFloat = UIScreen.main.bounds.width / minWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * minWidth)
                
                return width
            }
        }
        static var height: CGFloat {
            get {
                let ratio: CGFloat = (27 / 40)
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
                
                let primaryHeight = placeholder.height(withConstrainedWidth: K.Poster.width, font: primaryFont) * 2

                return primaryHeight + K.Poster.height + 5
            }
        }
        static var regularHeightWithSecondary: CGFloat {
            get {
                let placeholder = "Lorem"
                let primaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
                let secondaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
                
                let primaryHeight = placeholder.height(withConstrainedWidth: K.Poster.width, font: primaryFont) * 2
                let secondaryHeight = placeholder.height(font: secondaryFont) * 2
                
                return primaryHeight + secondaryHeight + K.Poster.height + 5
            }
        }
        
        static var featuredCellWidth: CGFloat {
            get {
                let screen = UIScreen.main.bounds
                let minWidth = screen.width > 500 ? screen.width / 2 : screen.width / 1.25
                let numberOfCells: CGFloat = screen.width / minWidth
                let width: CGFloat = (numberOfCells / numberOfCells) * minWidth
                
                // Account for the CollectionView insets
                return width - 40
            }
        }
        static var featuredCellHeight: CGFloat {
            get {
                let placeholder = "Lorem"
                let primaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
                let primaryHeight = placeholder.height(font: primaryFont) * 2
                
                let ratio: CGFloat = (16 / 9)
                let height: CGFloat = .getHeight(with: featuredCellWidth, using: ratio)
                
                return height + primaryHeight + 5
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
