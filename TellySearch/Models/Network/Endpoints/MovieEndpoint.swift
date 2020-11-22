//
//  MovieEndpoint.swift
//  TellySearch
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
            if type == .trending {
                return "/3/trending/movie/week"
            } else if type == .popular || type == .topRated || type == .recentlyReleased {
                return "/3/discover/movie"
            } else {
                return "\(basePath)/\(type.rawValue)"
            }
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
            URLQueryItem(name: "language", value: K.User.language)
        ]
        switch self {
        case .getOverview(let type):
            if type == .upcoming {
                params.append(URLQueryItem(name: "region", value: K.User.country))
            } else if type == .popular {
                params.append(URLQueryItem(name: "vote_count.gte", value: "300"))
                params.append(URLQueryItem(name: "vote_average.lte", value: "10"))
                params.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            } else if type == .topRated {
                params.append(URLQueryItem(name: "vote_count.gte", value: "300"))
                params.append(URLQueryItem(name: "sort_by", value: "vote_average.desc"))
            } else if type == .recentlyReleased {
                let date = Date()
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                let monthString = month > 10 ? "\(month)" : "0\(month)"
                let dayString = day > 10 ? "\(day)" : "0\(day)"
                let dateString = "\(year)-\(monthString)-\(dayString)"
                params.append(URLQueryItem(name: "vote_count.gte", value: "300"))
                params.append(URLQueryItem(name: "primary_release_date.lte", value: dateString))
                
                params.append(URLQueryItem(name: "region", value: K.User.country))
                params.append(URLQueryItem(name: "sort_by", value: "primary_release_date.desc"))
            }
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
