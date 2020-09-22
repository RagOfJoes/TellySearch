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

class MovieDetailRecommendations: GenericCollectionView {
    var movies: [Movie]?
    var colors: UIImageColors?
    weak var delegate: MovieDetailRecommendationsDelegate?
    
    override init(_ type: GenericCollectionViewType) {
        super.init(type)
    }
    
    func configure(with movies: [Movie], colors: UIImageColors) {
        self.movies = movies
        self.colors = colors
        
        self.setupHeader(title: "Recommendations", color: self.colors?.primary)
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CollectionView Setup
extension MovieDetailRecommendations {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMovie = movies?[indexPath.item] {
            self.delegate?.select(movie: safeMovie)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let moviesLen = movies?.count {
            return moviesLen
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell.reuseIdentifier, for: indexPath) as? RegularCell else {
            return UICollectionViewCell()
        }
        
        if let movie = movies?[indexPath.row] {
            if let safePoster = movie.posterPath {
                cell.configure(primary: movie.title, image: K.Poster.URL + safePoster, colors: self.colors)
            } else {
                cell.configure(primary: movie.title, colors: self.colors)
            }
        }
        
        return cell
    }
}
