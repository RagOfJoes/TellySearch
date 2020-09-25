//
//  ShowDetailSeasons.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class ShowDetailSeasons: GenericCollectionView {
    var seasons: [Season]?
    var colors: UIImageColors?
    
    weak var delegate: ShowDetailRecommendationsDelegate?
    
    override init(_ type: GenericCollectionViewType) {
        super.init(type)
    }
    
    func configure(with seasons: [Season], colors: UIImageColors) {
        self.colors = colors
        self.seasons = seasons
        self.setupHeader(title: "Seasons", color: self.colors?.primary)
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension ShowDetailSeasons {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        if let safeShow = seasons?[indexPath.item] {
        //            self.delegate?.select(show: safeShow)
        //        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let seasonsLen = seasons?.count {
            return seasonsLen
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell.reuseIdentifier, for: indexPath) as? RegularCell else {
            return UICollectionViewCell()
        }
        
        if let season = seasons?[indexPath.row] {
            let episodeCountStr = "\(season.episodeCount) episodes"
            if let safePoster = season.posterPath {
                cell.configure(primary: season.name, secondary: episodeCountStr, image: K.Poster.URL + safePoster, colors: self.colors)
            } else {
                cell.configure(primary: season.name, secondary: episodeCountStr, colors: self.colors)
            }
        }
        
        return cell
    }
}
