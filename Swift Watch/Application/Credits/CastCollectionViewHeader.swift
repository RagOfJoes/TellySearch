//
//  CastCollectionViewHeader.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/10/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class CastCollectionViewHeader: UIView {
    lazy var title: UILabel = {
        let title = UILabel()
        title.alpha = 0.4
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        
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
        backgroundColor = .clear
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            title.heightAnchor.constraint(equalToConstant: 30),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
