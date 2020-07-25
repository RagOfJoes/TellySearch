//
//  UIButton+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

extension UIButton {
    func pulse() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.15
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func pulse(duration: CFTimeInterval?, from: Double?, to: Double?) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = duration ?? 0.15
        pulse.fromValue = from ?? 0.95
        pulse.toValue = to ?? 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
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
