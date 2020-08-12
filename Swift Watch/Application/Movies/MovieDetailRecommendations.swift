//
//  MovieDetailRecommendations.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol MovieDetailRecommendationsDelegate: class {
    func select(movie: Movie)
    func didUpdateConstraints()
}

class MovieDetailRecommendations: UIView {
    var movies: [Movie]?
    var colors: UIImageColors?
    
    weak var delegate: MovieDetailRecommendationsDelegate?
    
    private lazy var header: CastCollectionViewHeader = {
        let header = CastCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.isSkeletonable = true
        header.skeletonCornerRadius = 5
        header.showAnimatedGradientSkeleton()
        
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        // Setup Layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        
        // Setup CollectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.isSkeletonable = true
        collectionView.skeletonCornerRadius = 5
        collectionView.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        
        collectionView.register(OverviewCell.self, forCellWithReuseIdentifier: OverviewCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(collectionView)
        setupAnchors()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        self.delegate?.didUpdateConstraints()
    }
    
    func configure(with _movies: [Movie], colors _colors: UIImageColors) {
        self.movies = _movies
        self.colors = _colors
        header.configure(with: "Recommendations")
        header.title.textColor = colors?.primary
        
        header.hideSkeleton()
        collectionView.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension MovieDetailRecommendations {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 30),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            collectionView.heightAnchor.constraint(equalToConstant: K.Overview.heightConstant),
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailRecommendations: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMovie = movies?[indexPath.item] {
            self.delegate?.select(movie: safeMovie)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: K.Overview.widthConstant, height: K.Overview.heightConstant)
    }
}

// MARK: - UICollectionViewDataSource
extension MovieDetailRecommendations: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let moviesLen = movies?.count {
            return moviesLen
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
        
        if let movie = movies?[indexPath.row] {
            if let safePoster = movie.posterPath {
                cell.configure(name: movie.title, poster: MovieSection.posterURL + safePoster)
            } else {
                cell.configure(name: movie.title)
            }
            cell.title.textColor = colors?.primary
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension MovieDetailRecommendations: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
}

