//
//  CastCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol CastCollectionViewDelegate: class {
    func select(cast: Cast)
}

class CastCollectionView: GenericCollectionView {
    var credits: Credits?
    var colors: UIImageColors?
    weak var delegate: CastCollectionViewDelegate?
    
    func configure(with credits: Credits, title: String, colors: UIImageColors) {
        self.colors = colors
        self.credits = credits
        setupHeader(title: title, color: colors.primary)
        hideSkeleton()
    }
}

// MARK: - UICollectionViewDelegate
extension CastCollectionView {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cast = credits?.cast?[indexPath.row] {
            delegate?.select(cast: cast)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let castLen = credits?.cast?.count {
            if castLen >= 10 {
                return 10
            } else if castLen > 0 && castLen < 10 {
                return castLen
            }
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegularCell2.reuseIdentifier, for: indexPath) as? RegularCell2 else {
            return UICollectionViewCell()
        }
        
        if let cast = credits?.cast?[indexPath.row], let safeColors = colors {
            guard let profile = cast.profilePath else {
                cell.configure(primary: cast.name, secondary: cast.character, colors: safeColors)
                return cell
            }
            cell.configure(primary: cast.name, secondary: cast.character, image: K.URL.Poster + profile, colors: safeColors)
        }
        
        return cell
    }
}
