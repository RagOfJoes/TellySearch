//
//  MovieHeaderCollectionReusableView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/26/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class OverviewHeader: UIView {
    lazy var title: UILabel = {
        let title = UILabel()
        title.setupFont(size: 22, weight: .bold)
        title.textColor = UIColor(named: "primaryTextColor")
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
        backgroundColor = .clear
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 65),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            title.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
