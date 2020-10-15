//
//  ShowsFeaturedCollectionView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class ShowsFeaturedCollectionView: CVTCell {
    // MARK: - Internal Properties
    override var type: T.CellType {
        return .Featured
    }
    
    var section: Int?
    var shows: [Show]? = nil
    weak var delegate: ShowsCollectionViewDelegate?
    
    // MARK: - Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(shows: [Show], section: Int) {
        self.shows = shows
        self.section = section
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate
extension ShowsFeaturedCollectionView {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let correctIndexPath = IndexPath(row: indexPath.row, section: section ?? indexPath.section)
        delegate?.select(show: correctIndexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = shows?.count {
            return count
        }
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
        
        if let show = shows?[indexPath.row] {
            if let backdrop = show.backdropPath {
                cell.configure(name: show.name, image: K.URL.Backdrop + backdrop)
                return cell
            } else {
                cell.configure(name: show.name)
            }
            
        }
        return cell
    }
}
