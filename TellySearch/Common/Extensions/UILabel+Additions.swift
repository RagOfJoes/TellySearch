//
//  UILabel+Additions.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

extension UILabel {
    func getNumberOfLines() -> Int {
        guard let text = self.text else { return 0 }
        // Set attributes
        let attributes = [NSAttributedString.Key.font: self.font]
        // Calculate the size of your UILabel by using the systemfont and the paragraph we created before. Edit the font and replace it with yours if you use another
        let labelSize = text.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        
        // Now we return the amount of lines using the ceil method
        let lines = ceil(CGFloat(labelSize.height) / self.font.lineHeight)
        
        return Int(lines)
    }
    
    func setupFont(size: CGFloat, weight: UIFont.Weight) {
        self.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))
    }
}
