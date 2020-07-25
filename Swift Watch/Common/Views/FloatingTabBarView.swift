//
//  FloatingTabBarView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

protocol FloatingTabBarViewDelegate: AnyObject {
    func did(selectIndex: Int)
}

/**
    A Floating Tab Bar View
 
    Initialize by defining an Array of Image Names and a (optional) background Color
 */
class FloatingTabBarView: UIView {
    weak var delegate: FloatingTabBarViewDelegate?
    
    var buttons: [UIButton] = []
    
    init(items: [String], backgroundColor bgColor: UIColor?) {
        super.init(frame: .zero)
        
        backgroundColor = bgColor ?? .white
        setupStackView(with: items)
        updateUI(selectedIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius: CGFloat = 20
        // Rounded Corners
        layer.cornerRadius = cornerRadius
        
        // Shadow
        layer.shadowOpacity = 0.14
        layer.shadowOffset = .zero
        layer.shadowRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    fileprivate func setupStackView(with items: [String]) {
        for (index, item) in items.enumerated() {
            let normalImage = UIImage(named: item)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            let selectedImage = UIImage(named: "\(item).fill")?.withRenderingMode(.alwaysTemplate) ?? normalImage
            
            let button: UIButton = UIButton.createButton(normalImage: normalImage, selectedImage: selectedImage, index: index)
            button.addTarget(self, action: #selector(changeTab(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        
        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    @objc fileprivate func changeTab(_ sender: UIButton) {
        sender.pulse()
        delegate?.did(selectIndex: sender.tag)
        updateUI(selectedIndex: sender.tag)
    }
    
    fileprivate func updateUI(selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                button.isSelected = true
                button.tintColor = .systemOrange
            } else {
                button.isSelected = false
                button.tintColor = UIColor(named: "secondaryTextColor")
            }
        }
    }
    
    func hideTabBar(_ hide: Bool) {
        if !hide {
            isHidden = hide
        }
        
        let animations = {
            self.alpha = hide ? 0 : 1
            self.transform = hide ? CGAffineTransform(translationX: 0, y: 10) : .identity
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: animations) { (_) in
            if hide {
                self.isHidden = hide
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
