//
//  MovieEndpoint.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/15/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum MovieEndpoint: Endpoint {
    case getDetail(id: Int)
    case getOverview(type: FetchTypes)
    
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
        let basePath: String = "/3/movie"
        switch self {
        case .getDetail(let id):
            return "\(basePath)/\(id)"
        case .getOverview(let type):
            return "\(basePath)/\(type.rawValue)"
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
        case .getOverview:
            break
        case .getDetail:
            params.append(URLQueryItem(name: "append_to_response", value: "credits,recommendations"))
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
