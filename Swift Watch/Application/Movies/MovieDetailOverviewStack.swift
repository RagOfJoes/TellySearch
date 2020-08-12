//
//  MovieDetailOverviewStack.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class MovieDetailOverviewStack: UIStackView {
    private lazy var overviewTitle: UILabel = {
        let overviewTitle = UILabel()
        overviewTitle.alpha = 0.4
        overviewTitle.numberOfLines = 1
        overviewTitle.translatesAutoresizingMaskIntoConstraints = false
        overviewTitle.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        
        overviewTitle.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        return overviewTitle
    }()
    
    private lazy var overviewText: UILabel = {
        let overviewText = UILabel()
        let font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        overviewText.font = font
        overviewText.numberOfLines = 0
        overviewText.translatesAutoresizingMaskIntoConstraints = false
        
        return overviewText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        addArrangedSubview(overviewTitle)
        addArrangedSubview(overviewText)
        setCustomSpacing(5, after: overviewTitle)
        translatesAutoresizingMaskIntoConstraints = false
        
        isSkeletonable = true
        skeletonCornerRadius = 5
        showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
    }
    
    func configure(title: String, text: String?, colors: UIImageColors) {
        var height: CGFloat
        if  let safeText = text {
            height = safeText.height(font: overviewText.font)
        } else {
            height = 0
        }
        overviewTitle.text = title
        overviewTitle.textColor = colors.primary
        
        overviewText.text = text
        overviewText.textColor = colors.primary
        
        overviewText.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
