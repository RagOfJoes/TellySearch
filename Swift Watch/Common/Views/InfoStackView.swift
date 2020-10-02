//
//  InfoStackView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/27/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol InfoStackViewDelegate: class {
    func didReadMore()
}

class InfoStackView: UIStackView {
    weak var delegate: InfoStackViewDelegate?
    
    private var hasReadMore: Bool = false
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        
        return titleLabel
    }()
    
    private lazy var readMore: UIButton = {
        let readMore = UIButton(type: .custom)
        readMore.setTitle("Show More", for: .normal)
        readMore.setTitle("Show Less", for: .selected)
        readMore.translatesAutoresizingMaskIntoConstraints = false
        return readMore
    }()
    
    private lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, readMore])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .bottom
        titleStackView.distribution = .fill
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return titleStackView
    }()
    
    private lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return valueLabel
    }()
    
    init(using colors: UIImageColors? = nil, hasReadMore: Bool = false, fontSize: (CGFloat, CGFloat) = (18, 14), fontWeight: (UIFont.Weight, UIFont.Weight) = (.bold, .medium)) {
        super.init(frame: .zero)
        axis = .vertical
        translatesAutoresizingMaskIntoConstraints = false
        setupFonts(fontSize: fontSize, weight: fontWeight)
        
        setupReadMore(enabled: hasReadMore)
        
        addArrangedSubview(titleStackView)
        addArrangedSubview(valueLabel)
        setCustomSpacing(2, after: titleStackView)
        
        isSkeletonable = true
        showAnimatedGradientSkeleton()
        
        guard let safeColors = colors else { return }
        setupColors(colors: safeColors)
    }
    
    func setup(title: String, value: String, colors: UIImageColors? = nil) {
        hideSkeleton()
        let valueText = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = title.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.valueLabel.text = valueText
            
            guard let safeValueLabel = self?.valueLabel else { return }
            
            if let safeHasReadMore = self?.hasReadMore, let safeReadMore = self?.readMore {
                if safeHasReadMore && safeValueLabel.getNumberOfLines() <= 3 {
                    self?.titleStackView.removeArrangedSubview(safeReadMore)
                    self?.readMore.removeFromSuperview()
                }
            }
            
            guard let safeColors = colors else { return }
            self?.setupColors(colors: safeColors)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action Handlers
extension InfoStackView {
    @objc func readMoreAction(_ sender: UIButton) {
        if !hasReadMore {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let safeReadMore = self?.readMore else { return }
            
            if safeReadMore.isSelected {
                self?.valueLabel.numberOfLines = 3
            } else {
                self?.valueLabel.numberOfLines = 0
            }
            safeReadMore.isSelected = !safeReadMore.isSelected
        }
        delegate?.didReadMore()
    }
}

// MARK: - Private Setup Functions
extension InfoStackView {
    private func setupColors(colors: UIImageColors) {
        readMore.setTitleColor(colors.detail, for: .normal)
        readMore.setTitleColor(colors.detail, for: .selected)
        titleLabel.textColor = colors.primary
        valueLabel.textColor = colors.secondary
    }
    
    private func setupFonts(fontSize: (CGFloat, CGFloat), weight: (UIFont.Weight, UIFont.Weight)) {
        titleLabel.setupFont(size: fontSize.0, weight: weight.0)
        valueLabel.setupFont(size: fontSize.1, weight: weight.1)
        readMore.titleLabel?.setupFont(size: fontSize.1, weight: weight.1)
        
        let placeholderText: String = "Lorem"
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: placeholderText.height(font: titleLabel.font) + 2),
            valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: placeholderText.height(font: valueLabel.font))
        ])
    }
    
    private func setupReadMore(enabled: Bool) {
        if enabled {
            valueLabel.numberOfLines = 3
            readMore.addTarget(self, action: #selector(readMoreAction), for: .touchUpInside)
            readMore.isUserInteractionEnabled = true
            
            hasReadMore = true
        } else {
            titleStackView.removeArrangedSubview(readMore)
            readMore.removeFromSuperview()
        }
    }
}
