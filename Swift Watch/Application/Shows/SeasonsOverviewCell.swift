//
//  SeasonsOverviewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/1/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class SeasonsOverviewCell: UICollectionReusableView {
    // MARK: - Internal Properties
    private lazy var airDate: InfoStackView = {
        let airDate = InfoStackView()
        return airDate
    }()
    
    private lazy var overview: InfoStackView = {
        let overview = InfoStackView()
        return overview
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(airDate)
        addSubview(overview)
        setupAnchors()
    }
    
    func configure(airDate: String?, overview: String?, colors: UIImageColors) {
        let airDateTitle = "First Air Date"
        if airDate != nil {
            let dateStr = airDate!.formatDate(format: "YYYY-MM-dd") { (month, day, year) -> String in
                return "\(month) \(day), \(year)"
            }
            
            self.airDate.setup(title: airDateTitle, value: dateStr ?? "-", colors: colors)
        } else {
            self.airDate.setup(title: airDateTitle, value: "-", colors: colors)
        }
        
        self.overview.setup(title: "Overview", value: overview ?? "-", colors: colors)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subview Setup
extension SeasonsOverviewCell {
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
            overview.topAnchor.constraint(equalTo: airDate.bottomAnchor, constant: 15)
        ]
        NSLayoutConstraint.activate(overviewConstraints)
    }
}

extension SeasonsOverviewCell: ReusableCell { }
