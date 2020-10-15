//
//  NetworkManager.swift
//  TellySearch
//
//  Created by Victor Ragojos on 10/15/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Cache
import Promises
import Foundation

struct NetworkManagerError: LocalizedError {
    private var description: String
    
    var title: String?
    var failureReason: String? { return description }
    var errorDescription: String? { return description }
    
    init(title: String = "NetworkManagerError", description: String) {
        self.title = title
        self.description = description
    }
}

class NetworkManager {
    class func request<T: Codable>(endpoint: Endpoint, cache: Storage<T>? = nil, cacheKey: String? = nil) -> Promise<T> {
        return Promise<T> { (fulfill, reject) in
            // 1
            // Check cache
            if cache != nil && cacheKey != nil, let cachedData = try? cache!.object(forKey: cacheKey!) {
                fulfill(cachedData)
                return
            } else if (cache != nil && cacheKey == nil) || (cache == nil && cacheKey != nil) {
                reject(NetworkManagerError(description: "If cache or cacheKey is provided then both have to be provided!"))
                return
            }
            
            // 2
            // Setup URLComponents
            var components = URLComponents()
            components.scheme = endpoint.scheme
            components.host = endpoint.baseURL
            components.path = endpoint.path
            // 2a
            // Ensure that Query Strings are only being used
            // for GET Requests
            if endpoint.method == .get {
                components.queryItems = endpoint.parameters
            }
            
            // 3
            // Construct URL
            guard let url = components.url else { return reject(NetworkManagerError(description: "Failed to construct URL")) }
            
            // 4
            // Construct Request
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = endpoint.method.rawValue
            if endpoint.method == .post {
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters, options: .prettyPrinted)
                } catch {
                    reject(NetworkManagerError(description: "Failed to Encode Body"))
                    return
                }
            }
            
            // 5
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
                if let e = error {
                    reject(e)
                    return
                }
                
                guard let safeData = data else {
                    reject(NetworkManagerError(description: "An Error has occured fetching Data"))
                    return
                }
                
                DispatchQueue.main.async {
                    if let responseObject = try? JSONDecoder().decode(T.self, from: safeData) {
                        if cache != nil && cacheKey != nil {
                            try? cache?.setObject(responseObject, forKey: cacheKey!)
                        }
                        
                        fulfill(responseObject)
                    } else {
                        reject(NetworkManagerError(description: "Failed to Decode JSON"))
                    }
                }
            }
            
            // 6
            dataTask.resume()
        }
    }
}
