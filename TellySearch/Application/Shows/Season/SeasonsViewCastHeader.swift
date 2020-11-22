//
//  SeasonsViewCastHeader.swift
//  TellySearch
//
//  Created by Victor Ragojos on 11/19/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView
import OctreePalette

class SeasonsViewCastHeader: UICollectionReusableView {
    // MARK: - Internal Properties
    private lazy var episodesLabel: CollectionViewHeader = {
        let episodesLabel = CollectionViewHeader()
        episodesLabel.isSkeletonable = true
        return episodesLabel
    }()
        
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(episodesLabel)
        setupAnchors()
        
        isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subview Setup
extension SeasonsViewCastHeader {
    func configure(count: Int?, colors: ColorTheme) {
        episodesLabel.configure("Episodes (\(count ?? 0))", color: colors.primary.uiColor)
    }
    
    private func setupAnchors() {
        let episodesConstraints: [NSLayoutConstraint] = [
            episodesLabel.topAnchor.constraint(equalTo: topAnchor),
            episodesLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            episodesLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(episodesConstraints)
    }
    
}

// MARK: - Reusable Cell
extension SeasonsViewCastHeader: ReusableCell { }
