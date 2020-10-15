//
//  FloatingTabBarView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

protocol FloatingTabBarViewDelegate: class {
    func did(selectIndex: Int)
}

/**
 A Floating Tab Bar View
 
 Initialize by defining an Array of Image Names and a (optional) background Color
 */
class FloatingTabBarView: UIView {
    // MARK: - Internal Properties
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20
    
    private var buttons: [UIButton] = []
    
    weak var delegate: FloatingTabBarViewDelegate?
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Life Cycle
    init(items: [String], shouldBlur: Bool = true) {
        super.init(frame: .zero)
        setupBackground()
        if shouldBlur {
            setupBlurView()
        }
        
        // Setup StackView
        addSubview(stackView)
        setupStackView(with: items)
        setupShadow()
        UIView.animate(withDuration: 0.2) {
            self.updateUI(selectedIndex: 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
        updateShadow()
    }
    
    func hideTabBar(_ hide: Bool) {
        if isHidden == hide { return }
        
        let duration: TimeInterval = 0.2
        
        isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = hide ? 0.0 : 1.0
            self.transform = hide ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
        }, completion: { (true) in
            self.isHidden = hide
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers
extension FloatingTabBarView {
    private func updateUI(selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            let tintColor: UIColor = .systemOrange
            let isSelected: Bool = index == selectedIndex
            let alpha: CGFloat = index == selectedIndex ? 1.0 : 0.4
            
            button.alpha = alpha
            button.tintColor = tintColor
            button.isSelected = isSelected
        }
    }
    
    @objc private func changeTab(_ sender: UIButton) {
        delegate?.did(selectIndex: sender.tag)
        
        UIView.animate(withDuration: 0.2) {
            self.updateUI(selectedIndex: sender.tag)
        }
    }
}

// MARK: - View Setup
extension FloatingTabBarView {
    private func setupBackground() {
        var bg: UIColor
        if #available(iOS 13, *) {
            bg = .systemBackground
        } else {
            if #available(iOS 12, *), traitCollection.userInterfaceStyle == .dark {
                bg = .black
            } else {
                bg = .white
            }
        }
        backgroundColor = bg
    }
    
    private func setupShadow() {
        if #available(iOS 12, *), traitCollection.userInterfaceStyle == .dark {
            
        } else {
            layer.contents = center
            layer.shadowRadius = 1.0
            layer.shadowOpacity = 0.12
            layer.masksToBounds = false
            layer.shouldRasterize = true
            layer.cornerRadius = cornerRadius
            layer.shadowColor = UIColor.black.cgColor
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
       
    }
    
    private func updateShadow() {
        if #available(iOS 12, *), traitCollection.userInterfaceStyle == .dark {
            
        } else {
            layer.shadowRadius = 5.0
            layer.shadowOpacity = 0.12
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    
    private func setupBlurView() {
        backgroundColor = .clear
        
        var blurEffect: UIBlurEffect!
        
        if #available(iOS 10.0, *) {
            blurEffect = UIBlurEffect(style: .dark)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.roundCorners(.allCorners, radius: 20)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView, at: 0)
    }
}

// MARK: - Subviews Setup
extension FloatingTabBarView {
    private func setupStackView(with items: [String]) {
        buttons = items.enumerated().map({ (item) -> UIButton in
            let (offset, element) = item
            let normalImage = UIImage(named: element)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            let selectedImage = UIImage(named: "\(element).fill")?.withRenderingMode(.alwaysTemplate) ?? normalImage
            
            let button: UIButton = .createButton(normalImage: normalImage, selectedImage: selectedImage, index: offset)
            button.addTarget(self, action: #selector(changeTab(_:)), for: .touchUpInside)
            return button
        })
        
        for button in buttons {
            DispatchQueue.main.async {
                self.stackView.addArrangedSubview(button)
            }
        }
        stackView.fillSuperview(padding: .init(top: 0, left: padding, bottom: 0, right: padding))
    }
}

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
