//
//  CreatorsCollectionViewCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol ConfigureCreatorsCollectionViewCell: ReusableCell {
    func configure(primary: String, secondary: String, color: UIColor)
}

class CreatorsCollectionViewCell: UICollectionViewCell {
    private lazy var primaryLabel: UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.numberOfLines = 1
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        primaryLabel.font = T.Typography(variant: .Body, weight: .bold).font
        
        return primaryLabel
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let secondaryLabel = UILabel()
        secondaryLabel.numberOfLines = 1
        secondaryLabel.font = T.Typography(variant: .Subtitle).font
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return secondaryLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        isSkeletonable = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)

        let primaryLabelConstraints: [NSLayoutConstraint] = [
            primaryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(primaryLabelConstraints)
        
        let secondarLabelConstraints: [NSLayoutConstraint] = [
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            secondaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(secondarLabelConstraints)
        
        isSkeletonable = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CreatorsCollectionViewCell: ConfigureCreatorsCollectionViewCell {
    static var reuseIdentifier = "CreatorCollectionViewCell"
    
    func configure(primary: String, secondary: String, color: UIColor) {
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: primaryLabel.font ?? T.Typography(variant: .Body, weight: .bold).font,
        ]
        let underlineString: NSAttributedString = NSAttributedString(string: primary, attributes: underlineAttributes)
        DispatchQueue.main.async { [weak self] in
            self?.secondaryLabel.text = secondary
            self?.primaryLabel.attributedText = underlineString
            
            self?.setupColors(color: color)
        }
    }
    
    private func setupColors(color: UIColor) {
        primaryLabel.textColor = color
        secondaryLabel.textColor = color
    }
}
