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
        photo.roundCorners([.topLeft, .topRight], radius: 5)
        photo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photo.widthAnchor.constraint(equalToConstant: K.Poster.width),
            photo.heightAnchor.constraint(equalToConstant: K.Poster.height)
        ])
        
        return photo
    }()
    
    lazy var primaryText: UILabel = {
        let primaryText = UILabel()
        primaryText.numberOfLines = 0
        primaryText.translatesAutoresizingMaskIntoConstraints = false
        primaryText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        
        return primaryText
    }()
    
    lazy var secondaryText: UILabel = {
        let secondaryText = UILabel()
        secondaryText.numberOfLines = 0
        secondaryText.clipsToBounds = true
        secondaryText.translatesAutoresizingMaskIntoConstraints = false
        secondaryText.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
        
        return secondaryText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 5
        
        contentView.addSubview(photo)
        contentView.addSubview(primaryText)
        contentView.addSubview(secondaryText)
        setupAnchors()
        
        isSkeletonable = true
        skeletonCornerRadius = 5
    }
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    func configure(with cast: Cast, colors: UIImageColors) {
        DispatchQueue.main.async {            
            self.primaryText.text = cast.name
            self.secondaryText.text = cast.character
            
            self.primaryText.textColor = colors.primary
            self.secondaryText.textColor = colors.secondary
            
            self.contentView.backgroundColor = colors.primary.withAlphaComponent(0.26)
        }
                
        let placeholder = UIImage(named: "placeholderPoster")
        guard let profilePath = cast.profilePath else {
            photo.image = placeholder
            return
        }
        
        let url = URL(string: K.Credits.profileURL + profilePath)
        let options: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
        ]
        self.photo.kfSetImage(with: url, using: placeholder, options: options)
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
