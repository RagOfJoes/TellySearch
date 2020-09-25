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
        guard let safeBirthday = self.birthday else { return nil }
        let date = Date(safeBirthday, with: "YYYY-MM-dd")
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLL"
        let releaseMonth = monthFormatter.string(from: date)
        
        let calendar = Calendar.current.dateComponents([.day, .year], from: date)
        let releaseDay = "\(calendar.day!)"
        let releaseYear = "\(calendar.year!)"
        
        return "\(releaseMonth) \(releaseDay), \(releaseYear)"
    }
    var died: String? {
        guard let safeDeathday = self.deathday else { return nil }
        let date = Date(safeDeathday, with: "YYYY-MM-dd")
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLL"
        let releaseMonth = monthFormatter.string(from: date)
        
        let calendar = Calendar.current.dateComponents([.day, .year], from: date)
        let releaseDay = "\(calendar.day!)"
        let releaseYear = "\(calendar.year!)"
        
        return "\(releaseMonth) \(releaseDay), \(releaseYear)"
    }
    var genderStr: String {
        switch self.gender {
        case 1:
            return "Female"
        case 2:
            return  "Male"
        default:
            return "-"
        }
    }
    var numberOfWorks: Int {
        return self.combinedCredits.cast.count + self.combinedCredits.crew.count
    }
    var notableWorks:  [Media]?  {
        if self.numberOfWorks < 4 {
            return nil
        }
        
        var range: Int
        var arr: [Media] = []
        var sortByVoteCount: [Media]
        if self.knownFor == "Acting" {            
            let uniqueArray = self.combinedCredits.cast.unique(on: \Media.id)
            sortByVoteCount = uniqueArray.sorted {
                return $0.voteCount > $1.voteCount
            }
        } else {
            let uniqueArray = self.combinedCredits.crew.unique(on: \Media.id)
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
