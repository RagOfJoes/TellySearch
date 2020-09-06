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
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
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
        isSkeletonable = true
        collectionView.prepareSkeleton { (done) in
            self.showAnimatedGradientSkeleton()
        }
        setupAnchors()
    }
    
    func configure(with movies: [Movie], colors: UIImageColors) {
        self.movies = movies
        self.colors = colors
        
        header.configure(with: "Recommendations")
        header.title.textColor = self.colors?.primary
        
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension MovieDetailRecommendations {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: K.Poster.height + 80),
            
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 30),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    
        var collectionViewLeading: NSLayoutConstraint!
        var collectionViewTrailing: NSLayoutConstraint!
        
        if #available(iOS 11, *) {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        } else {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        }
        
        let collectionViewConstraints: [NSLayoutConstraint] = [
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, constant: -35),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailRecommendations: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMovie = movies?[indexPath.item] {
            self.delegate?.select(movie: safeMovie)
        }
    }
}

extension MovieDetailRecommendations: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: K.Poster.width, height: collectionView.frame.height)
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
        
        cell.title.textColor = colors?.primary
        if let movie = movies?[indexPath.row] {
            if let safePoster = movie.posterPath {
                cell.configure(name: movie.title, image: K.Poster.URL + safePoster)
            } else {
                cell.configure(name: movie.title)
            }
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension MovieDetailRecommendations: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
}

