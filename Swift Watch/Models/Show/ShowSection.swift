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
    
    func fetchSection(with type: FetchTypes) -> Promise<[Show]> {
        let promise = Promise<[Show]>.pending()
        if let url = URL(string: "\(ShowSection.baseURL)/\(type.rawValue)?api_key=\(K.tmdbApiKey)&region=US") {
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
extension ShowSection {
    func parseJSON(_ tvData: Data) -> [Show]? {
        let decoder = JSONDecoder()
        do {
            let decodedTvSection = try decoder.decode(ShowSection.self, from: tvData)
            return decodedTvSection.results
        } catch {
            return nil
        }
    }
}
