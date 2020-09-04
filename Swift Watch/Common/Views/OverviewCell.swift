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
    func configure(name: String, image: String?)
}

class OverviewCell: UICollectionViewCell {
    lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 2
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
                
        return title
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
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(stackView)
        let stackViewConstraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: -45),
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
        
        isSkeletonable = true
        skeletonCornerRadius = 10
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
    
    func configure(name: String, image: String? = nil) {
        hideSkeleton()
        DispatchQueue.main.async {
            self.title.text = name
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
    }
}
