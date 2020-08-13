//
//  CastCollectionViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class CastCollectionViewCell: UICollectionViewCell {
    lazy var photo: UIImageView = {
        let photo = UIImageView()
        photo.clipsToBounds = true
        photo.contentMode = .scaleAspectFill
        photo.roundCorners([.topLeft, .topRight], radius: 10)
        photo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photo.widthAnchor.constraint(equalToConstant: K.Cast.topBilledCellWidth),
            photo.heightAnchor.constraint(equalToConstant: K.Cast.topBilledPosterHeight)
        ])
        
        return photo
    }()
    
    lazy var primaryText: UILabel = {
        let primaryText = UILabel()
        primaryText.numberOfLines = 0
        primaryText.translatesAutoresizingMaskIntoConstraints = false
        primaryText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .bold))
        
        return primaryText
    }()
    
    lazy var secondaryText: UILabel = {
        let secondaryText = UILabel()
        secondaryText.numberOfLines = 0
        secondaryText.clipsToBounds = true
        secondaryText.translatesAutoresizingMaskIntoConstraints = false
        secondaryText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .medium))
        
        return secondaryText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(photo)
        contentView.addSubview(primaryText)
        contentView.addSubview(secondaryText)
        setupAnchors()
        
        isSkeletonable = true
        skeletonCornerRadius = 10
        showAnimatedGradientSkeleton()
    }
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    func configure(with cast: Cast, colors: UIImageColors) {
        DispatchQueue.main.async {
            self.hideSkeleton()
            
            self.primaryText.text = cast.name
            self.secondaryText.text = cast.character
            
            self.primaryText.textColor = colors.primary
            self.secondaryText.textColor = colors.secondary
            
            self.contentView.layer.cornerRadius = 10
            self.contentView.backgroundColor = colors.primary.withAlphaComponent(0.26)
            
            let posterHeight = K.Cast.topBilledPosterHeight + 15
            let primaryTextHeight = cast.name.height(font: self.primaryText.font)
            let secondaryTextHeightConstraint: CGFloat = K.Cast.topBilledCellHeight - posterHeight - primaryTextHeight
            self.secondaryText.heightAnchor.constraint(lessThanOrEqualToConstant: secondaryTextHeightConstraint).isActive = true
        }
        
        
        guard let profilePath = cast.profilePath else {
            photo.image = UIImage(named: "placeholderPoster")
            return
        }
        
        let url = URL(string: Cast.profileURL + profilePath)
        
        DispatchQueue.main.async {
            self.photo.kfSetImage(with: url, using: UIImage(named: "placeholderPoster"))            
        }
    }
    
    private func setupAnchors() {
        let photoConstraints: [NSLayoutConstraint] = [
            photo.topAnchor.constraint(equalTo: contentView.topAnchor),
            photo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(photoConstraints)
        
        let primaryTextConstraints: [NSLayoutConstraint] = [
            primaryText.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 10),
            primaryText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            primaryText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ]
        NSLayoutConstraint.activate(primaryTextConstraints)
        
        let secondaryTextConstraints: [NSLayoutConstraint] = [
            secondaryText.topAnchor.constraint(equalTo: primaryText.bottomAnchor),
            secondaryText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            secondaryText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ]
        NSLayoutConstraint.activate(secondaryTextConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CastCollectionViewCell: SelfConfiguringCell {
    static var reuseIdentifier: String = "CastOverviewCell"
}
