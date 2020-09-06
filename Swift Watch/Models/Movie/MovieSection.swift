//
//  Movies.swift
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
    
    func fetchSection(with type: FetchTypes) -> Promise<[Movie]> {
        let promise = Promise<[Movie]>.pending()
        if let url = URL(string: "\(MovieSection.baseURL)/\(type.rawValue)?api_key=\(K.tmdbApiKey)&region=US") {
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }
                
                if let safeData = data {
                    if let payload = self.parseJSON(safeData) {
                        
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
    
    enum CodingKeys: String, CodingKey {
        case title
        case results
    }
}

// MARK: - Helper Functions
extension MovieSection {
    func parseJSON(_ movieData: Data) -> [Movie]? {
        let decoder = JSONDecoder()
        do {
            let decodedMovieSection = try decoder.decode(MovieSection.self, from: movieData)
            return decodedMovieSection.results
        } catch {
            return nil
        }
    }
}
