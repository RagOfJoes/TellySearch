//
//  MovieHeaderCollectionReusableView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/26/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class MovieSectionHeader: UIView {
    lazy var title: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 22, weight: .bold))
        
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
            heightAnchor.constraint(equalToConstant: 65),
            title.heightAnchor.constraint(equalToConstant: 30),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
