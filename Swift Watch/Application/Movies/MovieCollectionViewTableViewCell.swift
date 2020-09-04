//
//  MovieCollectionViewTableViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol MovieCollectionViewTableViewCellDelegate: class {
    func select(movie: IndexPath)
}

// MARK: - MovieCollectionViewTableViewCell
class MovieCollectionViewTableViewCell: UITableViewCell {
    var section: Int?
    var movies: [Movie]? = nil
    weak var delegate: MovieCollectionViewTableViewCellDelegate?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OverviewCell.self, forCellWithReuseIdentifier: OverviewCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.prepareSkeleton { (done) in
            self.collectionView.showAnimatedGradientSkeleton()
        }
        setupAnchors()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(movies: [Movie], section: Int) {
        self.movies = movies
        self.section = section
        self.collectionView.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension MovieCollectionViewTableViewCell {
    private func setupAnchors() {
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
            collectionView.heightAnchor.constraint(equalTo: heightAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor , constant: 10)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension MovieCollectionViewTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let correctIndexPath = IndexPath(row: indexPath.row, section: section ?? indexPath.section)
        self.delegate?.select(movie: correctIndexPath)
        return
    }
}

extension MovieCollectionViewTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = movies?.count {
            return count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
        
        if let movie = movies?[indexPath.row] {
            if let poster = movie.posterPath {
                cell.configure(name: movie.title, image: MovieSection.posterURL + poster)
                return cell
            } else {
                cell.configure(name: movie.title)
            }
        }
        
        return cell
    }
}

extension MovieCollectionViewTableViewCell: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
}

// MARK: - UICollectionViewLayout
extension MovieCollectionViewTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: K.Poster.width, height: height)
    }
}
