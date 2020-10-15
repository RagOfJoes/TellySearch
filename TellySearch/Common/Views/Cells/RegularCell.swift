//
//  RegularCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

protocol ConfigurableRegularCell: ReusableCell {
    func configure(primary: String, image: String?, colors: UIImageColors?)
}

class RegularCell: UICollectionViewCell {
    private lazy var primaryLabel: UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.numberOfLines = 2
        primaryLabel.textColor = UIColor(named: "primaryTextColor")
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = T.Typography(variant: .Body, weight: .bold).font
        
        return primaryLabel
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

extension RegularCell {
    private func getLabelHeight() -> CGFloat {
        let placeholder = "Lorem"
        let primaryFont = T.Typography(variant: .Body, weight: .bold).font
        let primaryHeight = placeholder.height(font: primaryFont) * CGFloat(primaryLabel.numberOfLines) + T.Spacing.Vertical(size: .small)
        
        return primaryHeight
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
            primaryLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: T.Spacing.Vertical(size: .small))
        ])
    }
}

extension RegularCell: ConfigurableRegularCell {
    func configure(primary: String, image: String? = nil, colors: UIImageColors? = nil) {
        DispatchQueue.main.async {
            self.primaryLabel.text = primary
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
    
    private func setupColors(colors: UIImageColors) {
        primaryLabel.textColor = colors.primary
    }
}
