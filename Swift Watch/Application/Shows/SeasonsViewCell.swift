//
//  SeasonsViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class SeasonsViewCell: UITableViewCell {
    // MARK: - Internal Properties
    static let height: CGFloat = SeasonsViewCell.backdropHeight + "".height(withConstrainedWidth: SeasonsViewCell.backdropWidth, font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15, weight: .semibold))) * 2 + 5
    static let backdropWidth: CGFloat = UIScreen.main.bounds.width - 40
    static let backdropHeight: CGFloat = .getHeight(with: SeasonsViewCell.backdropWidth, using: (16 / 9))
    
    private lazy var backdrop: UIImageView = {
        let backdrop = UIImageView()
        backdrop.clipsToBounds = true
        backdrop.contentMode = .scaleAspectFill
        backdrop.roundCorners([.topLeft, .topRight], radius: 5)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        backdrop.isSkeletonable = true
        backdrop.skeletonCornerRadius = 5
        return backdrop
    }()
    
    private lazy var nameBackground: UIView = {
        let nameBackground = UIView()
        nameBackground.translatesAutoresizingMaskIntoConstraints = false
        nameBackground.roundCorners([.bottomLeft, .bottomRight], radius: 5)
        
        let lorem = ""
        let height = lorem.height(withConstrainedWidth: SeasonsViewCell.backdropWidth, font: self.name.font) * 2
        nameBackground.heightAnchor.constraint(equalToConstant: height + 5).isActive = true
        return nameBackground
    }()
    
    private lazy var name: UILabel = {
        let name = UILabel()
        name.numberOfLines = 2
        name.setupFont(size: 15, weight: .semibold)
        name.textColor = UIColor(named: "primaryTextColor")
        name.translatesAutoresizingMaskIntoConstraints = false
        
        return name
    }()
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupShadows()
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        contentView.addSubview(backdrop)
        contentView.addSubview(nameBackground)
        contentView.addSubview(name)
        
        isSkeletonable = true
        
        setupAnchors()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        shrink(down: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        shrink(down: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        shrink(down: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View setup
extension SeasonsViewCell {
    private func setupAnchors() {
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            backdrop.heightAnchor.constraint(equalToConstant: SeasonsViewCell.backdropHeight)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let nameConstraints: [NSLayoutConstraint] = [
            nameBackground.topAnchor.constraint(equalTo: backdrop.bottomAnchor),
            nameBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            name.centerYAnchor.constraint(equalTo: nameBackground.centerYAnchor),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
        ]
        NSLayoutConstraint.activate(nameConstraints)
    }
    
    private func setupShadows() {
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.23
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

// MARK: - Subviews setup
extension SeasonsViewCell {
    func configure(url: String? = nil, name: String, colors: UIImageColors? = nil) {
        let placeholder = UIImage(named: "placeholderBackdrop")
        
        if let urlString = url {
            let validURL = URL(string: urlString)
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            self.backdrop.kfSetImage(with: validURL, using: placeholder, options: options)
        } else {
            backdrop.image = placeholder
        }
        
        self.name.text = name
        
        guard let safeColors = colors else { return }
        setupColors(colors: safeColors)
    }
    
    private func setupColors(colors: UIImageColors) {
        name.textColor = colors.primary
        
        let background = colors.background
        
        // Unwrap background and check if it's light
        if background != nil, background?.isLight() != nil, background!.isLight()! {
            nameBackground.backgroundColor = background?.darker(by: 16)
        } else {
            nameBackground.backgroundColor = background?.lighter(by: 18)
        }
    }
}

// MARK: - Reusable Cell
extension SeasonsViewCell: ReusableCell {
    
}
