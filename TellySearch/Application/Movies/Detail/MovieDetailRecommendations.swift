//
//  MovieDetailRecommendations.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import OctreePalette

protocol MovieDetailRecommendationsDelegate: class {
    func select(movie: Movie)
}

class MovieDetailRecommendations: HorizontalCollectionView {
    var movies: [Movie]?
    var colors: ColorTheme?
    weak var delegate: MovieDetailRecommendationsDelegate?

    func configure(with movies: [Movie], colors: ColorTheme) {
        self.movies = movies
        self.colors = colors
        setupHeader(title: "Recommendations", color: colors.primary.uiColor)
    }
}

// MARK: - UICollectionViewDelegate
extension MovieDetailRecommendations {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMovie = movies?[indexPath.item] {
            delegate?.select(movie: safeMovie)
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
                cell.configure(primary: movie.title, image: K.URL.Poster + safePoster, colors: colors)
            } else {
                cell.configure(primary: movie.title, colors: colors)
            }
        }
        
        return cell
    }
}
