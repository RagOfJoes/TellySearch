//
//  String+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat = UIApplication.shared.windows[0].bounds.width, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func formatDate(format: String = "MM-DD-YYYY", monthFormat: String = "LLL", formatter: ((_ month: String, _ day: Int, _ year: Int) -> String)? = nil) -> String? {
        var releaseMonth: String?
        var releaseDay: Int?
        var releaseYear: Int?
        
        if self.count <= 0 {
            return nil
        }
        
        let date = Date(self, with: "YYYY-MM-dd")
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLL"
        releaseMonth = monthFormatter.string(from: date)
        
        let calendar = Calendar.current.dateComponents([.day, .year], from: date)
        releaseDay = calendar.day
        releaseYear = calendar.year
        
        if releaseMonth != nil && releaseYear != nil && releaseDay != nil {
            if formatter != nil {
                return formatter!(releaseMonth!, releaseDay!, releaseYear!)
            }
            
            return "\(releaseMonth!) \(releaseDay!), \(releaseYear!)"
        }
        
        return nil
    }
}
