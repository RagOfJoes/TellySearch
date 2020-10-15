//
//  MovieHeaderCollectionReusableView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/26/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class OverviewHeader: UIView {
    private lazy var title: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "primaryTextColor")
        title.font = T.Typography(variant: .HeadingOne).font
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func configure(with text: String) {
        title.text = text
    }
    
    private func setupUI() {
        isSkeletonable = true
        
        backgroundColor = .clear
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -T.Spacing.Vertical()),
            title.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            title.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
