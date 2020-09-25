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
    private let detailStorage = C.Person
    
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
    }
}

// MARK: - Cast Movie Detail Handler
extension Cast {
    func fetchDetail() -> Promise<Data> {
        let cacheKey = "person:\(self.id):detail"
        return Promise<Data>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            // Check if cached then fulfill and return early
            if let cached = try? detailStorage?.object(forKey: cacheKey) {
                fullfill(cached)
                return
            }
            
            let urlString = "\(K.Credits.baseURL)/\(id)\(K.CommonQuery)&append_to_response=combined_credits"
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(CreditFetchError(description: "An Error has occured fetching Cast Detail Data"))
                        return
                    }
                    
                    try? detailStorage?.setObject(safeData, forKey: cacheKey)
                    fullfill(safeData)
                }).resume()
            } else {
                reject(CreditFetchError(description: "An Invalid URL was provided"))
            }
        })
    }
}
