//
//  SeasonDetail.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct SeasonDetail: Codable {
    let credits: Credits?
    let episodes: [Episode]?
    
    enum CodingKeys: String, CodingKey {
        case credits
        case episodes
    }
}

extension SeasonDetail {
    static func decodeSeasonData(data: Data) -> Promise<SeasonDetail> {
        return Promise<SeasonDetail>(on: .promises, { (fullfill, reject) in
            do {
                let decoder = JSONDecoder()
                let decodedShowDeatail = try decoder.decode(SeasonDetail.self, from: data)
                
                fullfill(decodedShowDeatail)
                return
            } catch {
                reject(ShowFetchError(description: "An Error has occured decoding Season Detail Data"))
            }
        })
    }
}
