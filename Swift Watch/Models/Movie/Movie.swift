//
//  Movie.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct MovieFetchError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "MovieFetchError", description: String) {
        self.title = title
        self.description = description
    }
}

struct Movie: Codable {
    private let detailStorage = C.Movie
    
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let backdropPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - Movie Detail Handler
extension Movie {
    func fetchDetail() -> Promise<Data> {
        let cacheKey = "movie:\(id):detail"
        
        return Promise<Data>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            // Check if cached then fulfill and return early
            if let cached = try? detailStorage?.object(forKey: cacheKey) {
                fullfill(cached)
                return
            }
            
            let urlString = "\(K.URL.Movie)/\(id)\(K.CommonQuery)&append_to_response=credits,recommendations"
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(MovieFetchError(description: "An Error has occured fetching Movie Detail Data"))
                        return
                    }
                    
                    try? detailStorage?.setObject(safeData, forKey: cacheKey)
                    fullfill(safeData)
                }).resume()
            } else {
                reject(MovieFetchError(description: "An Invalid URL was provided"))
            }
        })
    }
}
