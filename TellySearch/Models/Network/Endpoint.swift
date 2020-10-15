//
//  Endpoint.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/14/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public typealias HTTPHeaders = [String: String]

protocol Endpoint {
    /// "HTTP" or "HTTPS"
    var scheme: String { get }
    
    /// Example: "api.themoviedb.org"
    var baseURL: String { get }
    
    /// Example: "/movies"
    var path: String { get }
    
    /// Example: ["Content-Type": "application/json"]
    var headers: HTTPHeaders { get }
    
    /// [URLQueryItem(name: "id", value: 1)]
    var parameters: [URLQueryItem] { get }
    
    //. .get | .put | .post | .patch | .delete
    var method: HTTPMethod { get }
}
