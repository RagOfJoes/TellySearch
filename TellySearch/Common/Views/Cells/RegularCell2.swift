//
//  RegularCell2.swift
//  TellySearch
//
//  Created by Victor Ragojos on 10/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView
import OctreePalette

protocol ConfigurableRegularCell2: ReusableCell {
    func configure(primary: String, secondary: String?, image: String?, colors: ColorTheme?)
}

class RegularCell2: UICollectionViewCell {
    private lazy var primaryLabel: UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.numberOfLines = 2
        primaryLabel.textColor = UIColor(named: "primaryTextColor")
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = T.Typography(variant: .Body, weight: .bold).font
        
        return primaryLabel
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let secondaryLabel = UILabel()
        secondaryLabel.numberOfLines = 2
        secondaryLabel.textColor = UIColor(named: "secondaryTextColor")
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = T.Typography(variant: .Subtitle, weight: .medium).font
        
        return secondaryLabel
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = 5
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)
        
        setupAnchors()
        isSkeletonable = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RegularCell2 {
    private func getLabelHeight() -> CGFloat {
        let placeholder = "Lorem"
        let primaryFont = T.Typography(variant: .Body, weight: .bold).font
        let primaryHeight = placeholder.height(font: primaryFont) * 2 + T.Spacing.Vertical(size: .small)
        
        let secondaryFont = T.Typography(variant: .Subtitle, weight: .medium).font
        let secondaryHeight = placeholder.height(font: secondaryFont) * 2
        
        return primaryHeight + secondaryHeight
    }
    
    private func setupAnchors() {
        let labelHeight: CGFloat = getLabelHeight()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -labelHeight),
            
            primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: T.Spacing.Vertical(size: .small)),
            
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            secondaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

extension RegularCell2: ConfigurableRegularCell2 {
    func configure(primary: String, secondary: String? = "-", image: String? = nil, colors: ColorTheme? = nil) {
        DispatchQueue.main.async {
            self.primaryLabel.text = primary
            self.secondaryLabel.text = secondary
        }
        
        let placeholder = UIImage(named: "placeholderPoster")
        if let safePoster = image {
            let url = URL(string: safePoster)
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            imageView.kfSetImage(with: url, using: placeholder, options: options)
        } else {
            imageView.image = placeholder
        }
        
        guard let safeColors = colors else { return }
        setupColors(colors: safeColors)
    }
    
    private func setupColors(colors: ColorTheme) {
        primaryLabel.textColor = colors.primary.uiColor
        secondaryLabel.textColor = colors.secondary.uiColor
    }
}
