//
//  Show.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/3/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Cache
import Promises
import Foundation

struct ShowFetchError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "ShowFetchError", description: String) {
        self.title = title
        self.description = description
    }
}

struct Show: Codable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String
    let backdropPath: String?
    
//    private let detailStorage = try? Storage(
//        diskConfig: DiskConfig(name: "MovieDetail"),
//        memoryConfig: MemoryConfig(
//            // Expire objects in 6 hours
//            expiry: .date(Date().addingTimeInterval(60 * 60 * 6)),
//            /// The maximum number of objects in memory the cache should hold
//            countLimit: 50,
//            /// The maximum total cost that the cache can hold before it starts evicting objects
//            totalCostLimit: 0
//        ), transformer: TransformerFactory.forCodable(ofType: MovieDetail.self)
//    )
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
    }
}

// MARK: - Show Detail Handler
extension Show {
    func fetchDetail() -> Promise<ShowDetail> {
//        let cacheKey = "movie:\(self.id):detail"
        let promise = Promise<ShowDetail>.pending()

        // Check if cached
//        if let cachedDetail = try? detailStorage?.object(forKey: cacheKey) {
//            // Fulfill Promise and return early
//            promise.fulfill(cachedDetail)
//            return promise
//        }
        let urlString = "\(ShowSection.baseURL)/\(id)\(K.CommonQuery)&append_to_response=credits,recommendations"
        if let url  = URL(string: urlString) {
            let session = URLSession(configuration: .default)

            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }

                if let safeData = data {
                    if let payload = self.parseDetail(safeData) {
                        // Set to cache
//                        try? self.detailStorage?.setObject(payload, forKey: cacheKey)

                        // Fulfill Promise
                        promise.fulfill(payload)
                    } else {
                        promise.reject(ShowFetchError(description: "An Error has occured parsing fetched Show Data"))
                    }
                } else {
                    promise.reject(ShowFetchError(description: "An Error has occured fetching Show Data"))
                }

            }).resume()
        } else {
            promise.reject(ShowFetchError(description: "An Invalid URL was provided"))
        }

        return promise
    }

    private func parseDetail(_ showData: Data) -> ShowDetail? {
        let decoder = JSONDecoder()

        // ".self" after the WeatherData refers to the Type of
        // the Decodable struct
        do {
            let decodedDetail = try decoder.decode(ShowDetail.self, from: showData)
            return decodedDetail
        } catch {
            return nil
        }
    }
}
