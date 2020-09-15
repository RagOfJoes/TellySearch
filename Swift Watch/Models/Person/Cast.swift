//
//  Cast.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Cache
import Promises
import Foundation

struct Cast: Codable {    
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    
    private let castDetailStorage = try? Storage(
        diskConfig: DiskConfig(name: "CastDetail"),
        memoryConfig: MemoryConfig(
            // Expire objects in 6 hours
            expiry: .date(Date().addingTimeInterval(60 * 60 * 6)),
            /// The maximum number of objects in memory the cache should hold
            countLimit: 50,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            totalCostLimit: 0
        ), transformer: TransformerFactory.forCodable(ofType: Media.self)
    )
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}

// MARK: - Cast Movie Detail Handler
extension Cast {
    func fetchDetails() -> Promise<PersonDetail> {
        let cacheKey = "cast:\(self.id):detail"
        let promise = Promise<PersonDetail>.pending()
        
        // Check if cached
        // if let cachedDetail = try? castDetailStorage?.object(forKey: cacheKey) {
            // Fulfill Promise and return early
            // promise.fulfill(cachedDetail)
            // return promise
        // }
        let urlString = "\(K.Credits.baseURL)/\(id)\(K.CommonQuery)&append_to_response=combined_credits"
        if let url  = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }
                
                if let safeData = data {
                    if let payload = self.parseDetail(safeData) {
                        // Set to cache
                        // try? self.castDetailStorage?.setObject(payload, forKey: cacheKey)
                        
                        // Fulfill Promise
                        promise.fulfill(payload)
                    } else {
                        promise.reject(MovieFetchError(description: "An Error has occured parsing fetched Cast Detail"))
                    }
                } else {
                    promise.reject(MovieFetchError(description: "An Error has occured fetching Cast Detail"))
                }
                
            }).resume()
        } else {
            promise.reject(MovieFetchError(description: "An Invalid URL was provided"))
        }
        
        return promise
    }
    
    private func parseDetail(_ data: Data) -> PersonDetail? {
        let decoder = JSONDecoder()
        
        // ".self" after the WeatherData refers to the Type of
        // the Decodable struct
        do {
            let decodedDetail = try decoder.decode(PersonDetail.self, from: data)
            return decodedDetail
        } catch {
            return nil
        }
    }
}
