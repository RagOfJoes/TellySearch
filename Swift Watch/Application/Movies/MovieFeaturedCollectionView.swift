//
//  MovieFeaturedCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class MovieFeaturedCollectionView: CVTCell {
    var section: Int?
    var movies: [Movie]? = nil
    weak var delegate: MovieCollectionViewTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure(.Featured)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(movies: [Movie], section: Int) {
        self.movies = movies
        self.section = section
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension MovieFeaturedCollectionView {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let correctIndexPath = IndexPath(row: indexPath.row, section: section ?? indexPath.section)
        self.delegate?.select(movie: correctIndexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = movies?.count {
            return count
        }
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
        
        if let movie = movies?[indexPath.row] {
            if let backdrop = movie.backdropPath {
                cell.configure(name: movie.title, image: K.Backdrop.URL + backdrop)
                return cell
            } else {
                cell.configure(name: movie.title)
            }
            
        }
        return cell
    }
}
