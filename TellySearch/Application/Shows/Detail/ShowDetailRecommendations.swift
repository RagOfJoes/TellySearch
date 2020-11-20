//
//  ShowDetailRecommendations.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/13/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView
import OctreePalette

protocol ShowDetailRecommendationsDelegate: class {
    func select(show: Show)
}

class ShowDetailRecommendations: HorizontalCollectionView {
    var shows: [Show]?
    var colors: ColorTheme?
    
    weak var delegate: ShowDetailRecommendationsDelegate?

    func configure(with shows: [Show], colors: ColorTheme) {
        self.shows = shows
        self.colors = colors
        setupHeader(title: "Recommendations", color: colors.primary.uiColor)
    }
}

// MARK: - UICollectionViewDelegate
extension ShowDetailRecommendations {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeShow = shows?[indexPath.item] {
            delegate?.select(show: safeShow)
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
                cell.configure(primary: show.name, image: K.URL.Poster + safePoster, colors: colors)
            } else {
                cell.configure(primary: show.name, colors: colors)
            }
        }
        
        return cell
    }
}
