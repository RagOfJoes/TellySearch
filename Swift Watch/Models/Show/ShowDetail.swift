//
//  ShowDetail.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

struct CrewIds: Codable {
    let id: Int
    let name: String
}

struct ShowDetail: Codable {
    let runtime: Int?
    let rateAvg: Double
    let genres: [Genre]?
    let tagline: String?
    let seasons: [Season]
    let credits: Credits?
    let episodeRunTime: [Int?]
    let createdByIds: [CrewIds]
    let recommendations: ShowSection?
    
    var createdBy: [Crew]? {
        get {
            var arr: [Crew] = []
            guard let safeCredits = self.credits else { return nil }
            guard let safeCrew = safeCredits.crew else { return nil }
            
            for id in createdByIds {
                if let found = safeCrew.firstIndex(where: { return $0.id == id.id }) {
                    arr.append(safeCrew[found])
                } else {
                    arr.append(Crew(id: id.id, job: "Creator", name: id.name, department: "-", profilePath: nil))
                }
            }
            
            return arr.count > 0 ? arr : nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case genres
        case seasons
        case tagline
        case runtime
        case credits
        case recommendations
        case rateAvg = "vote_average"
        case createdByIds = "created_by"
        case episodeRunTime = "episode_run_time"
    }
}
