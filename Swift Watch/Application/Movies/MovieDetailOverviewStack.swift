//
//  MovieDetailOverviewStack.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class MovieDetailOverviewStack: UIStackView {
    private lazy var overviewTitle: UILabel = {
        let overviewTitle = UILabel()
        overviewTitle.alpha = 0.4
        overviewTitle.numberOfLines = 1
        overviewTitle.translatesAutoresizingMaskIntoConstraints = false
        overviewTitle.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
                
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
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        isSkeletonable = true
        skeletonCornerRadius = 5
        showAnimatedGradientSkeleton()
        
        addArrangedSubview(overviewTitle)
        addArrangedSubview(overviewText)
        setCustomSpacing(5, after: overviewTitle)
    }
    
    func configure(title: String, text: String?, colors: UIImageColors) {
        overviewTitle.text = title
        overviewTitle.textColor = colors.primary
        
        overviewText.text = text
        overviewText.textColor = colors.primary
        
        hideSkeleton()
    }
    
    func overviewHeight() -> CGFloat {
        if let text = overviewText.text {
            return text.height(font: overviewText.font)
        }
        
        return 0
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
