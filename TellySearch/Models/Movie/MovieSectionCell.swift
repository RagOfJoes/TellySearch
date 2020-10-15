//
//  MovieSectionCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct MovieSectionCell {
    let type: T.CellType
    let section: MovieSection
    let request: Promise<MovieSection>
}
