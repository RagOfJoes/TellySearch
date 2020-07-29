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
    
    init(title: String?, description: String) {
        self.description = description
        self.title = title ?? "MovieFetchError"
    }
    
    init(description: String) {
        self.title = "MovieFetchError"
        self.description = description
    }
}

// MARK: - MovieSection
struct MovieSection: Codable {
    static let baseURL = "https://api.themoviedb.org/3/movie"
    static let imageURL = "https://image.tmdb.org/t/p/original"
    
    // Section Title
    let title: String?
    
    // Actual Payload
    var results: [Movie]?
    
    init(title: String) {
        self.title = title
    }
    
    init(title: String, results: [Movie]) {
        self.title = title
        self.results = results
    }
    
    func fetchSection(with type: MovieFetchType, _ completion: @escaping ([Movie]?, Error?) -> Void) {
        // Create URL
        guard let url = URL(string: "\(MovieSection.baseURL)/\(type.rawValue)?api_key=\(K.tmdbApiKey)") else {
            completion(nil, MovieFetchError(description: "URL Provided was invalid"))
            return
        }
        
        // Create Session
        let session = URLSession(configuration: .default)
        
        // Give Session a task
        // completionHandler looks for a closure
        // which acts similarly to JS closure
        // let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil, let e = error {
                completion(nil, e)
                return
            }
            
            if let safeData = data {
                // Inside a closure we must provide
                // "self." to call an external function
                if let payload = self.parseJSON(safeData) {
                    
                    completion(payload, nil)
                } else {
                    completion(nil, MovieFetchError(description: "An Error has occured parsing fetched Movie Data"))
                }
            } else {
                completion(nil, MovieFetchError(description: "An Error has occured fetching Movie Data"))
            }
            
        })
        
        // Start the Task
        task.resume()
    }
    
    func fetchSection(with type: MovieFetchType) -> Promise<[Movie]> {
        let promise = Promise<[Movie]>.pending()
        // Create URL
        if let url = URL(string: "\(MovieSection.baseURL)/\(type.rawValue)?api_key=\(K.tmdbApiKey)&region=US") {
            // Create Session
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil, let e = error {
                    promise.reject(e)
                }
                
                if let safeData = data {
                    // Inside a closure we must provide
                    // "self." to call an external function
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
        
        // ".self" after the WeatherData refers to the Type of
        // the Decodable struct
        do {
            let decodedMovieSection = try decoder.decode(MovieSection.self, from: movieData)
            return decodedMovieSection.results
        } catch {
            return nil
        }
    }
    
    mutating func set(results: [Movie]) {
        self.results = results
    }
}
