//
//  SeasonsViewHeader.swift
//  TellySearch
//
//  Created by Victor Ragojos on 10/1/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView
import OctreePalette

class SeasonsViewHeader: UICollectionReusableView {
    // MARK: - Internal Properties
    private let airDate: InfoStackView = InfoStackView()
    private let overview: InfoStackView = InfoStackView()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(airDate)
        addSubview(overview)
        setupAnchors()
        
        isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subview Setup
extension SeasonsViewHeader {
    func configure(airDate: String?, overview: String?, colors: ColorTheme) {
        self.airDate.setup(title: "Air Date", value: airDate ?? "-", colors: colors)
        self.overview.setup(title: "Overview", value: overview ?? "-", colors: colors)
    }
    
    private func setupAnchors() {
        let airDateConstraints: [NSLayoutConstraint] = [
            airDate.topAnchor.constraint(equalTo: topAnchor),
            airDate.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            airDate.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(airDateConstraints)
        
        let overviewConstraints: [NSLayoutConstraint] = [
            overview.topAnchor.constraint(equalTo: airDate.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            overview.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            overview.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(overviewConstraints)
    }
}

// MARK: - Reusable Cell
extension SeasonsViewHeader: ReusableCell { }
