//
//  GenericCollectionViewHeader.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/21/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class GenericCollectionViewHeader: UIView {
    private lazy var title: UILabel = {
        let title = UILabel()
        title.font = T.Typography(variant: .Title).font
        title.textColor = UIColor(named: "primaryTextColor")
        title.translatesAutoresizingMaskIntoConstraints = false

        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func configure(_ text: String, color: UIColor? = nil) {
        title.text = text
        
        if color != nil {
            title.textColor = color
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(title)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),
            title.heightAnchor.constraint(equalTo: heightAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
