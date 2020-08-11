//
//  CastCollectionViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher
import SkeletonView

class CastCollectionViewCell: UICollectionViewCell {
    lazy var photo: UIImageView = {
        let photo = UIImageView()
        photo.clipsToBounds = true
        photo.contentMode = .scaleAspectFill
        photo.roundCorners([.topLeft, .topRight], radius: 10)
        photo.translatesAutoresizingMaskIntoConstraints = false
        
        DispatchQueue.main.async {
            photo.isSkeletonable = true
            photo.skeletonCornerRadius = 10
            photo.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))            
        }
        
        NSLayoutConstraint.activate([
            photo.heightAnchor.constraint(equalToConstant: 160),
            photo.widthAnchor.constraint(equalToConstant: CastCollectionView.collectionViewCellWidth),
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
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: contentView.topAnchor),
            photo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            primaryText.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 10),
            primaryText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            primaryText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            secondaryText.topAnchor.constraint(equalTo: primaryText.bottomAnchor),
            secondaryText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            secondaryText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CastCollectionViewCell: SelfConfiguringCell {
    static var reuseIdentifier: String = "CastOverviewCell"
}
