//
//  MovieCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/24/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher

protocol MovieConfigureCell: SelfConfiguringCell {
    func configure(with movie: Movie)
}

class MovieCell: UICollectionViewCell {
    lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 2
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .medium))
        
        title.sizeToFit()
        return title
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        return imageView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, title])
        stackView.axis = .vertical
        stackView.setCustomSpacing(5, after: imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension MovieCell: MovieConfigureCell {
    static let reuseIdentifier: String = "Movie Cell"
    
    func configure(with movie: Movie) {
        title.text = movie.title
        
        guard let safePoster = movie.posterPath else {
            imageView.image = UIImage(named: "placeholderPoster")
            return
        }
        let url = URL(string: MovieSection.imageURL + safePoster)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderPoster"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
        ])
    }
}
