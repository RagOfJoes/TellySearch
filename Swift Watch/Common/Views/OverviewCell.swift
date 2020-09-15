//
//  MovieCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

protocol OverviewConfigureCell: SelfConfiguringCell {
    func configure(primary: String, secondary: String?, image: String?, colors: UIImageColors?)
}

class OverviewCell: UICollectionViewCell {
    lazy var primaryLabel: UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.numberOfLines = 2
        primaryLabel.setupFont(size: 14, weight: .bold)
        primaryLabel.textColor = UIColor(named: "primaryTextColor")
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        primaryLabel.isSkeletonable = true
        return primaryLabel
    }()
    
    lazy var secondaryLabel: UILabel = {
        let secondaryLabel = UILabel()
        secondaryLabel.numberOfLines = 2
        secondaryLabel.setupFont(size: 13, weight: .medium)
        secondaryLabel.textColor = UIColor(named: "secondaryTextColor")
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return secondaryLabel
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.roundCorners(.allCorners, radius: 5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isSkeletonable = true
        imageView.skeletonCornerRadius = 5
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: K.Poster.width),
            imageView.heightAnchor.constraint(equalToConstant: K.Poster.height),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),

            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            secondaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        isSkeletonable = true
        skeletonCornerRadius = 5
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
extension OverviewCell: OverviewConfigureCell {
    static var reuseIdentifier = "OverviewCell"
    
    func configure(primary: String, secondary: String? = nil, image: String? = nil, colors: UIImageColors? = nil) {
        self.hideSkeleton()
        DispatchQueue.main.async {
            self.primaryLabel.text = primary
            
            if let safeSecondary = secondary {
                self.secondaryLabel.text = safeSecondary
            } else {
                self.secondaryLabel.removeFromSuperview()
            }
        }
        
        if let safePoster = image {
            let url = URL(string: safePoster)
            let placeholder = UIImage(named: "placeholderPoster")
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            self.imageView.kfSetImage(with: url, using: placeholder, options: options)
        } else {
            imageView.image = UIImage(named: "placeholderPoster")
        }
        
        guard let safeColors = colors else { return }
        setupColors(colors: safeColors)
    }
    
    private func setupColors(colors: UIImageColors) {
        primaryLabel.textColor = colors.primary
        secondaryLabel.textColor = colors.secondary
    }
}
