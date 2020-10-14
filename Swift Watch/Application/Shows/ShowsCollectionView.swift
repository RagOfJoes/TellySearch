//
//  ShowsCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol ShowsCollectionViewDelegate: class {
    func select(show: IndexPath)
}

class ShowsCollectionView: CVTCell {
    // MARK: - Internal Properties
    override var type: T.CellType {
        return .Regular
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
extension ShowsCollectionView {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let correctIndexPath = IndexPath(row: indexPath.row, section: section ?? indexPath.section)
        delegate?.select(show: correctIndexPath)
        return
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = shows?.count {
            return count
        }
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell.reuseIdentifier, for: indexPath) as! RegularCell
        
        if let show = shows?[indexPath.row] {
            if let poster = show.posterPath {
                cell.configure(primary: show.name, image: K.URL.Poster + poster)
                return cell
            } else {
                cell.configure(primary: show.name)
            }
        }
        
        return cell
    }
}
