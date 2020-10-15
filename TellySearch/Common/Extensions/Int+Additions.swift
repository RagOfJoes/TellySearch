//
//  Int+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/5/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

extension Int {
    /**
        Converts seconds to (Hours, Minutes, Seconds)
     */
    func secondsToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func minutesToHoursMinutes(minutes: Int) -> (Int, Int) {
        return ((minutes % 3600) / 60, (minutes % 3600) % 60)
    }
}
