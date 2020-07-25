//
//  Date+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import Foundation

extension Date {
    init(_ dateString: String, with format: String = "MM-DD-YYYY") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = dateFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }
}
