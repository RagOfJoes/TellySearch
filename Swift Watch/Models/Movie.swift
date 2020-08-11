//
//  Movie.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Cache
import Promises
import Kingfisher
import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    
    private let detailStorage = try? Storage(
        diskConfig: DiskConfig(name: "MovieDetail"),
        memoryConfig: MemoryConfig(
            // Expire objects in 6 hours
            expiry: .date(Date().addingTimeInterval(60 * 60 * 6)),
            /// The maximum number of objects in memory the cache should hold
            countLimit: 50,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            totalCostLimit: 0
        ), transformer: TransformerFactory.forCodable(ofType: MovieDetail.self)
    )
    
    private let creditStorage = try?  Storage(
        diskConfig: DiskConfig(name: "MovieCredits"),
        memoryConfig: MemoryConfig(
            // Expire objects in 6 hours
            expiry: .date(Date().addingTimeInterval(60 * 60 * 6)),
            /// The maximum number of objects in memory the cache should hold
            countLimit: 50,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            totalCostLimit: 0
        ), transformer: TransformerFactory.forCodable(ofType: Credits.self)
    )
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - Helper Function
extension Movie {
    func fetchDetail() -> Promise<MovieDetail> {
        let cacheKey = "movie:\(self.id):detail"
        let promise = Promise<MovieDetail>.pending()
        
        // Check if Detail hsa already been cached
        if let cachedDetail = try? detailStorage?.object(forKey: cacheKey) {
            // Fulfill Promise and return early
            promise.fulfill(cachedDetail)
            return promise
        }
        
        if let url  = URL(string: "\(MovieSection.baseURL)/\(id)?api_key=\(K.tmdbApiKey)&language=en-US") {
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }
                
                if let safeData = data {
                    if let payload = self.parseDetail(safeData) {
                        // Set to cache
                        try? self.detailStorage?.setObject(payload, forKey: cacheKey)
                        
                        // Fulfill Promise
                        promise.fulfill(payload)
                    } else {
                        promise.reject(MovieFetchError(description: "An Error has occured parsing fetched Movie Data"))
                    }
                } else {
                    promise.reject(MovieFetchError(description: "An Error has occured fetching Movie Data"))
                }
                
            }).resume()
        } else {
            promise.reject(MovieFetchError(description: "An Invalid URL was provided"))
        }
        
        return promise
    }
    
    func fetchCredits() -> Promise<Credits> {
        let cacheKey = "movie:\(self.id):credits"
        let promise = Promise<Credits>.pending()
        
        // Check if Detail hsa already been cached
        if let cachedCredits = try? creditStorage?.object(forKey: cacheKey) {
            // Fulfill Promise and return early
            promise.fulfill(cachedCredits)
            return promise
        }
        
        if let url  = URL(string: "\(MovieSection.baseURL)/\(id)/credits?api_key=\(K.tmdbApiKey)&language=en-US") {
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }
                
                if let safeData = data {
                    if let payload = self.parseCredits(safeData) {
                        // Set to cache
                        try? self.creditStorage?.setObject(payload, forKey: cacheKey)
                        
                        // Fulfill Promise
                        promise.fulfill(payload)
                    } else {
                        promise.reject(MovieFetchError(description: "An Error has occured parsing fetched Movie Credits"))
                    }
                } else {
                    promise.reject(MovieFetchError(description: "An Error has occured fetching Movie Credits"))
                }
                
            }).resume()
        } else {
            promise.reject(MovieFetchError(description: "An Invalid URL was provided"))
        }
        
        return promise
    }
    
    private func parseDetail(_ movieData: Data) -> MovieDetail? {
        let decoder = JSONDecoder()
        
        // ".self" after the WeatherData refers to the Type of
        // the Decodable struct
        do {
            let decodedDetail = try decoder.decode(MovieDetail.self, from: movieData)
            return decodedDetail
        } catch {
            return nil
        }
    }
    
    private func parseCredits(_ movieCredits: Data) -> Credits? {
        let decoder = JSONDecoder()
        
        // ".self" after the WeatherData refers to the Type of
        // the Decodable struct
        do {
            let decodedDetail = try decoder.decode(Credits.self, from: movieCredits)
            return decodedDetail
        } catch {
            return nil
        }
    }
}
