//
//  CGFloat+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

extension CGFloat {
    static func getHeight(with width: CGFloat, using ratio: CGFloat) -> CGFloat {
        return width / ratio
    }
    
    static func getWidth(with height: CGFloat, using ratio: CGFloat) -> CGFloat {
        return ((height) / (sqrt(1 / (pow(ratio, 2)) + 1)))
    }
}
