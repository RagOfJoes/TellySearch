//
//  Show.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/3/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

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
    private let detailStorage = C.Show
    
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let firstAirDate: String
    let backdropPath: String?
    
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
    func fetchDetail() -> Promise<Data> {
        let cacheKey = "show:\(self.id):detail"
        
        return Promise<Data>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            // Check if cached then fulfill and return early
            if let cached = try? detailStorage?.object(forKey: cacheKey) {
                fullfill(cached)
                return
            }
            
            let urlString = "\(ShowSection.baseURL)/\(id)\(K.CommonQuery)&append_to_response=credits,recommendations"
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(ShowFetchError(description: "An Error has occured fetching Show Detail Data"))
                        return
                    }
                    
                    try? detailStorage?.setObject(safeData, forKey: cacheKey)
                    fullfill(safeData)
                }).resume()
            } else {
                reject(ShowFetchError(description: "An Invalid URL was provided"))
            }
        })
    }
}
