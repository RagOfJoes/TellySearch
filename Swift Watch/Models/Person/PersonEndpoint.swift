//
//  PersonEndpoint.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/15/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum PersonEndpoint: Endpoint {
    case getPersonDetail(id: Int)
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return K.URL.Base
        }
    }
    
    var path: String {
        let basePath: String = "/3/person"
        switch self {
        case .getPersonDetail(let id):
            return "\(basePath)/\(id)"
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var parameters: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: K.TmdbApiKey),
            URLQueryItem(name: "region", value: K.User.country),
            URLQueryItem(name: "language", value: K.User.language)
        ]
        switch self {
        case .getPersonDetail:
            params.append(URLQueryItem(name: "append_to_response", value: "combined_credits"))
            break
        }
        
        return params
    }
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
}
