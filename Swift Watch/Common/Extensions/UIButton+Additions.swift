//
//  UIButton+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

extension UIButton {
    static func createButton(normalImage: UIImage, selectedImage: UIImage?, index: Int) -> UIButton {
        let button = UIButton()
        button.constrainWidth(constant: 60)
        button.constrainHeight(constant: 60)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage ?? normalImage, for: .selected)
        button.tag = index
        button.adjustsImageWhenHighlighted = false
                
        return button
    }
}
