//
//  CreditDetailNotableWorks.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/31/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol CreditDetailNotableWorksDelegate: class {
    func select(media: Media)
}

class CreditDetailNotableWorks: HorizontalCollectionView {
    var media: [Media]?
    let colors: UIImageColors
    weak var delegate: CreditDetailNotableWorksDelegate?
    
    init(colors: UIImageColors) {
        self.colors = colors
        super.init(.RegularSecondary)
    }
    
    func configure(with media: [Media]) {
        self.media = media
        setupHeader(title: "Notable Works", color: colors.primary)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CollectionView Setup
extension CreditDetailNotableWorks {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMedia = media?[indexPath.item] {
            delegate?.select(media: safeMedia)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let safeWorksLen = media?.count {
            return safeWorksLen
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell2.reuseIdentifier, for: indexPath) as? RegularCell2 else {
            return UICollectionViewCell()
        }
        
        if let media = media?[indexPath.row] {
            let primary = media.name ?? media.title ?? "-"
            let secondary = media.character ?? media.job ?? "-"
            if let safePoster = media.posterPath {
                cell.configure(primary: primary, secondary: secondary, image: K.URL.Poster + safePoster, colors: colors)
            } else {
                cell.configure(primary: primary, secondary: secondary, colors: colors)
            }
        }
        
        return cell
    }
}
