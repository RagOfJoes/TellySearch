//
//  SeasonsViewHeader.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/1/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class SeasonsViewHeader: UICollectionReusableView {
    // MARK: - Internal Properties
    private lazy var airDate: InfoStackView = {
        let airDate = InfoStackView()
        return airDate
    }()
    
    private lazy var overview: InfoStackView = {
        let overview = InfoStackView()
        return overview
    }()
    
    private lazy var castView: CastCollectionView = {
        let castView = CastCollectionView(.RegularHasSecondary)
        return castView
    }()
    
    private lazy var episodesLabel: GenericCollectionViewHeader = {
        let episodesLabel = GenericCollectionViewHeader()
        episodesLabel.translatesAutoresizingMaskIntoConstraints = false
        episodesLabel.isSkeletonable = true
        return episodesLabel
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(airDate)
        addSubview(overview)
        addSubview(castView)
        addSubview(episodesLabel)
        setupAnchors()
        
        isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views Setup
extension SeasonsViewHeader {
    func setCastViewDelegate(_ delegate: CastCollectionViewDelegate) {
        castView.delegate = delegate
    }
}

// MARK: - Subview Setup
extension SeasonsViewHeader {
    func configure(airDate: String?, overview: String?, episodes: Int?, credits: Credits?, colors: UIImageColors) {
        self.airDate.setup(title: "Air Date", value: airDate ?? "-", colors: colors)
        self.overview.setup(title: "Overview", value: overview ?? "-", colors: colors)
        
        if let safeCredits = credits, let cast = safeCredits.cast, cast.count > 0 {
            castView.configure(with: safeCredits, title: "Season's Cast", colors: colors)
        } else {
            castView.removeFromSuperview()
            episodesLabel.topAnchor.constraint(equalTo: self.overview.bottomAnchor, constant: 35).isActive = true
        }
        
        episodesLabel.configure("Episodes (\(episodes ?? 0))", color: colors.primary)
    }
    
    private func setupAnchors() {
        let airDateConstraints: [NSLayoutConstraint] = [
            airDate.topAnchor.constraint(equalTo: topAnchor),
            airDate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            airDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(airDateConstraints)
        
        let overviewConstraints: [NSLayoutConstraint] = [
            overview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            overview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            overview.topAnchor.constraint(equalTo: airDate.bottomAnchor, constant: 35)
        ]
        NSLayoutConstraint.activate(overviewConstraints)
        
        let castViewConstraints: [NSLayoutConstraint] = [
            castView.leadingAnchor.constraint(equalTo: leadingAnchor),
            castView.trailingAnchor.constraint(equalTo: trailingAnchor),
            castView.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: 35)
        ]
        NSLayoutConstraint.activate(castViewConstraints)
 
        let episodesConstraints: [NSLayoutConstraint] = [
            episodesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            episodesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            episodesLabel.topAnchor.constraint(equalTo: castView.bottomAnchor, constant: 35)
        ]
        NSLayoutConstraint.activate(episodesConstraints)
    }
}

// MARK: - Reusable Cell
extension SeasonsViewHeader: ReusableCell { }
