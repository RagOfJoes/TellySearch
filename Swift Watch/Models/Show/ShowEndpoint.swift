//
//  ShowEndpoint.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/14/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum ShowEndpoint: Endpoint {
    case getShowDetail(id: Int)
    case getOverview(type: FetchTypes)
    case getSeasonDetail(tvId: Int, seasonNumber: Int)
    
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
        let basePath: String = "/3/tv"
        switch self {
        case .getShowDetail(let id):
            return "\(basePath)/\(id)"
        case .getOverview(let type):
            return "\(basePath)/\(type.rawValue)"
        case .getSeasonDetail(let tvId, let seasonNumber):
            return "\(basePath)/\(tvId)/season/\(seasonNumber)"
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
        case .getShowDetail:
            params.append(URLQueryItem(name: "append_to_response", value: "credits,recommendations"))
            break
        case .getOverview:
            break
        case .getSeasonDetail:
            params.append(URLQueryItem(name: "append_to_response", value: "credits"))
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
