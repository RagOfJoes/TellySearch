//
//  ShowDetailRecommendations.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/13/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol ShowDetailRecommendationsDelegate: class {
    func select(show: Show)
}

class ShowDetailRecommendations: UIView {
    var shows: [Show]?
    var colors: UIImageColors?
    
    weak var delegate: ShowDetailRecommendationsDelegate?
    
    private lazy var header: CastCollectionViewHeader = {
        let header = CastCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.isSkeletonable = true
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
    
    func configure(with shows: [Show], colors: UIImageColors) {
        self.shows = shows
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
extension ShowDetailRecommendations {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: K.Overview.regularHeight + 35),

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
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2),
            collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeight)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension ShowDetailRecommendations: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeShow = shows?[indexPath.item] {
            self.delegate?.select(show: safeShow)
        }
    }
}

extension ShowDetailRecommendations: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: K.Poster.width, height: collectionView.frame.height)
    }
}

// MARK: - UICollectionViewDataSource
extension ShowDetailRecommendations: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let moviesLen = shows?.count {
            return moviesLen
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
        
        if let show = shows?[indexPath.row] {
            if let safePoster = show.posterPath {
                cell.configure(primary: show.name, image: K.Poster.URL + safePoster, colors: self.colors)
            } else {
                cell.configure(primary: show.name, colors: self.colors)
            }
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension ShowDetailRecommendations: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
}

