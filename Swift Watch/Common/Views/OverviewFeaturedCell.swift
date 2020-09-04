//
//  OverviewFeaturedCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

protocol OverviewFeaturedConfigureCell: SelfConfiguringCell {
    func configure(name: String, image: String?)
}

class OverviewFeaturedCell: UICollectionViewCell {
    lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 2
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        
        return title
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(title)
        contentView.addSubview(imageView)
        let stackViewConstraints: [NSLayoutConstraint] = [
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -45),
            
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
        
        isSkeletonable = true
        skeletonCornerRadius = 5
        showAnimatedGradientSkeleton()
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
extension OverviewFeaturedCell: OverviewFeaturedConfigureCell {
    static var reuseIdentifier = "OverviewFeaturedCell"
    
    func configure(name: String, image: String? = nil) {
        DispatchQueue.main.async {
            self.hideSkeleton()
            self.title.text = name
        }
        
        if let safeImage = image {
            let url = URL(string: safeImage)
            let placeholder = UIImage(named: "placeholderBackdrop")
            let roundCorner = RoundCornerImageProcessor(cornerRadius: imageView.layer.cornerRadius)
            let options: KingfisherOptionsInfo = [
                .processor(roundCorner),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            self.imageView.kfSetImage(with: url, using: placeholder, options: options)
        }
    }
}
