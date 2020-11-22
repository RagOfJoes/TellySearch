//
//  FeaturedCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

protocol ConfigurableFeaturedCell: ReusableCell {
    func configure(name: String, image: String?)
}

class FeaturedCell: UICollectionViewCell {
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
    
    private lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 2
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = T.Typography(variant: .Body, weight: .bold).font
        
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        clipsToBounds = true
        
        contentView.addSubview(title)
        contentView.addSubview(imageView)
        
        let placeholder = "Lorem"
        let primaryFont = T.Typography(variant: .Body, weight: .bold).font
        let primaryHeight = placeholder.height(font: primaryFont) * 2
        let stackViewConstraints: [NSLayoutConstraint] = [
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -(primaryHeight + T.Spacing.Vertical(size: .small))),
            
            title.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: T.Spacing.Vertical(size: .small)),
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
        
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
extension FeaturedCell: ConfigurableFeaturedCell {    
    func configure(name: String, image: String? = nil) {
        DispatchQueue.main.async {
            self.title.text = name
        }
        
        let placeholder = UIImage(named: "placeholderBackdrop")
        if let safeImage = image {
            let url = URL(string: safeImage)
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            imageView.kfSetImage(with: url, using: placeholder, options: options)
        } else {
            imageView.image = placeholder
        }
    }
}
