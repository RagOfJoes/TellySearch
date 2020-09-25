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

class ShowDetailRecommendations: GenericCollectionView {
    var shows: [Show]?
    var colors: UIImageColors?
    
    weak var delegate: ShowDetailRecommendationsDelegate?
    
    override init(_ type: GenericCollectionViewType) {
        super.init(type)
    }
    
    func configure(with shows: [Show], colors: UIImageColors) {
        self.shows = shows
        self.colors = colors
        self.setupHeader(title: "Recommendations", color: self.colors?.primary)
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension ShowDetailRecommendations {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeShow = shows?[indexPath.item] {
            self.delegate?.select(show: safeShow)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let showsLen = shows?.count {
            return showsLen
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell.reuseIdentifier, for: indexPath) as? RegularCell else {
            return UICollectionViewCell()
        }
        
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
