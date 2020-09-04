//
//  MovieSectionCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

enum OverviewSectionCellType {
    case regular
    case featured
}

struct MovieSectionCell {
    let section: MovieSection
    let type: OverviewSectionCellType
}
