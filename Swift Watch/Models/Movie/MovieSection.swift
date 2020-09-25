//
//  Movies.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

// MARK: - MovieSection
struct MovieSection: Codable {
    static let baseURL = "https://api.themoviedb.org/3/movie"
    
    // Section Title
    let title: String?
    let results: [Movie]?
    
    init(title: String, results: [Movie]? = nil) {
        self.title = title
        self.results = results
    }
    
    func fetchSection(with type: FetchTypes) -> Promise<Data> {
        return Promise<Data>(on: .global(qos: .userInitiated)) { (fullfill, reject) in
            if let url = URL(string: "\(MovieSection.baseURL)/\(type.rawValue)\(K.CommonQuery)") {
                let session = URLSession(configuration: .default)
                
                session.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let e = error {
                        reject(e)
                        return
                    }
                    
                    guard let safeData = data else {
                        reject(MovieFetchError(description: "An Error has occured fetching Movie Section Data"))
                        return
                    }
                    
                    fullfill(safeData)
                }).resume()
            } else {
                reject(MovieFetchError(description: "An Invalid URL was provided"))
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case results
    }
}

// MARK: - Helper Functions
extension MovieSection {
    static func decodeMovieSection(data: Data) -> Promise<[Movie]> {
        return Promise<[Movie]>(on: .global(qos: .userInitiated), { (fullfill, reject) in
            do {
                let decoder = JSONDecoder()
                let decodedMovieSection = try decoder.decode(MovieSection.self, from: data)
                
                guard let results = decodedMovieSection.results else {
                    reject(MovieFetchError(description: "An Error has occured parsing fetched Movie Data"))
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
