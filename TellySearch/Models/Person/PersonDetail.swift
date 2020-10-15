//
//  PersonDetail.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct CombinedCredis: Codable {
    let cast: [Media]
    let crew: [Media]
}

struct PersonDetail: Codable {    
    let id: Int
    let gender: Int
    let knownFor: String
    let birthday: String?
    let deathday: String?
    let biography: String
    let birthPlace: String?
    
    let job: String?
    let character: String?
    
    let combinedCredits: CombinedCredis
    
    var born: String? {
        guard let safeBirthday = birthday else { return nil }
        return safeBirthday.formatDate(format: "YYYY-MM-dd") { (month, day, year) -> String in
            return "\(month) \(day), \(year)"
        }
    }
    var died: String? {
        guard let safeDeathday = deathday else { return nil }
        return safeDeathday.formatDate(format: "YYYY-MM-dd") { (month, day, year) -> String in
            return "\(month) \(day), \(year)"
        }
    }
    var genderStr: String {
        switch gender {
        case 1:
            return "Female"
        case 2:
            return  "Male"
        default:
            return "-"
        }
    }
    var numberOfWorks: Int {
        return combinedCredits.cast.count + combinedCredits.crew.count
    }
    var notableWorks:  [Media]?  {
        if numberOfWorks < 4 {
            return nil
        }
        
        var range: Int
        var arr: [Media] = []
        var sortByVoteCount: [Media]
        if knownFor == "Acting" {
            let uniqueArray = combinedCredits.cast.unique(on: \Media.id)
            sortByVoteCount = uniqueArray.sorted {
                return $0.voteCount > $1.voteCount
            }
        } else {
            let uniqueArray = combinedCredits.crew.unique(on: \Media.id)
            let knownForArray = uniqueArray.filter {
                return $0.department == self.knownFor
            }
            
            sortByVoteCount = knownForArray.sorted {
                return $0.voteCount > $1.voteCount
            }
        }
        range = sortByVoteCount.count > 10 ? 10 : sortByVoteCount.count
        
        for index in 0..<range {
            arr.append(sortByVoteCount[index])
        }
        
        return arr
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case job
        case gender
        case birthday
        case deathday
        case character
        case biography
        case birthPlace = "place_of_birth"
        case knownFor = "known_for_department"
        case combinedCredits = "combined_credits"
    }
}

extension PersonDetail {
    static func decodePersonDetail(data: Data) -> Promise<PersonDetail> {
        return Promise<PersonDetail>(on: .promises, { (fullfill, reject) in
            do {
                let decoder = JSONDecoder()
                let decodedPersonDetail = try decoder.decode(PersonDetail.self, from: data)
                
                fullfill(decodedPersonDetail)
                return
            } catch {
                reject(CreditFetchError(description: "An Error has occured decoding Person Detail Data"))
            }
        })
    }
}
