//
//  ShowSectionCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Promises
import Foundation

struct ShowSectionCell {
    let type: T.CellType
    let section: ShowSection
    let request: Promise<ShowSection>
}
