//
//  People.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

protocol Person: Codable {
    var id: Int { get }
    var name: String { get }
    var profilePath: String? { get }
}
