//
//  SeasonsViewCastCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 11/18/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import OctreePalette

class SeasonsViewCastCell: UICollectionViewCell {
    // MARK: - Internal Properties
    weak var castViewDelegate: CastCollectionViewDelegate?
    private lazy var castView: CastCollectionView = {
        let castView = CastCollectionView(.RegularSecondary)
        return castView
    }()

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(self.castView)
        
        isSkeletonable = true
        setupAnchors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Functions
extension SeasonsViewCastCell {
    private func setupAnchors() {
        let castViewConstraints: [NSLayoutConstraint] = [
            self.castView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.castView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            self.castView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activate(castViewConstraints)
    }
    
    func configure(credits: Credits?, colors: ColorTheme) {
        if let safeCredits = credits, let cast = safeCredits.cast, cast.count > 0 {
            self.castView.delegate = castViewDelegate
            self.castView.configure(with: safeCredits, title: "Season's Cast", colors: colors)
        } else {
            self.castView.removeFromSuperview()
        }
    }
}

extension SeasonsViewCastCell: ReusableCell { }
