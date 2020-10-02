//
//  Season.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct Season: Codable {
    let id: Int
    let name: String
    let airDate: String?
    let overview: String?
    let episodeCount: Int
    let seasonNumber: Int
    let posterPath: String?
    private let detailStorage = C.Season
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case airDate = "air_date"
        case posterPath = "poster_path"
        case episodeCount = "episode_count"
        case seasonNumber = "season_number"
    }
}

extension Season {
    func fetchDetail(tvId: Int) -> Promise<Data> {
        let cacheKey = "season:\(id):detail"
        
        return Promise<Data>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            // Check if cached then fulfill and return early
            if let cached = try? detailStorage?.object(forKey: cacheKey) {
                fullfill(cached)
                return
            }
            
            let urlString = "\(ShowSection.baseURL)/\(tvId)/season/\(seasonNumber)\(K.CommonQuery)&append_to_response=credits"
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(ShowFetchError(description: "An Error has occured fetching Season Detail Data"))
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
