//
//  ShowDetailSeasons.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol ShowDetailSeasonsDelegate: class {
    func select(season: Season)
}

class ShowDetailSeasons: HorizontalCollectionView {
    var seasons: [Season]?
    var colors: UIImageColors?
    
    weak var delegate: ShowDetailSeasonsDelegate?
    
    func configure(with seasons: [Season], colors: UIImageColors) {
        self.colors = colors
        self.seasons = seasons
        setupHeader(title: "Seasons", color: self.colors?.primary)
    }
}

// MARK: - UICollectionViewDelegate
extension ShowDetailSeasons {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeSeason = seasons?[indexPath.item] {
            delegate?.select(season: safeSeason)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let seasonsLen = seasons?.count {
            return seasonsLen
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell2.reuseIdentifier, for: indexPath) as? RegularCell2 else {
            return UICollectionViewCell()
        }
        
        if let season = seasons?[indexPath.row] {
            let episodeCountStr = "\(season.episodeCount) episodes"
            if let safePoster = season.posterPath {
                cell.configure(primary: season.name, secondary: episodeCountStr, image: K.URL.Poster + safePoster, colors: colors)
            } else {
                cell.configure(primary: season.name, secondary: episodeCountStr, colors: colors)
            }
        }
        
        return cell
    }
}
