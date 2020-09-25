//
//  ShowSection.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct ShowSection: Codable {
    static let baseURL = "https://api.themoviedb.org/3/tv"
    
    // Section Title
    let title: String?
    let results: [Show]?
    
    init(title: String, results: [Show]? = nil) {
        self.title = title
        self.results = results
    }
    
    func fetchSection(with type: FetchTypes) -> Promise<Data> {
        return Promise<Data>(on: .global(qos: .userInitiated)) { (fullfill, reject) in
            if let url = URL(string: "\(ShowSection.baseURL)/\(type.rawValue)\(K.CommonQuery)") {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(ShowFetchError(description: "An Error has occured fetching Show Section Data"))
                        return
                    }
                    
                    fullfill(safeData)
                }).resume()
            } else {
                reject(ShowFetchError(description: "An Invalid URL was provided"))
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case results
    }
}


// MARK: - Helper Functions
extension ShowSection {
    static func decodeShowSection(data: Data) -> Promise<[Show]> {
        return Promise<[Show]>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            do {
                let decoder = JSONDecoder()
                let decodedShowSection = try decoder.decode(ShowSection.self, from: data)
                
                guard let results = decodedShowSection.results else {
                    reject(ShowFetchError(description: "An Error has occured parsing fetched Show Data"))
                    return
                }
                
                fullfill(results)
                return
            } catch {
                reject(error)
            }
        })
    }
}
