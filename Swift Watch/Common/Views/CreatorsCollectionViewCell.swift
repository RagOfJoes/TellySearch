//
//  CreatorsCollectionViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol ConfigureCreatorsCollectionViewCell: SelfConfiguringCell {
    func configure(primary: String, secondary: String, color: UIColor)
}

class CreatorsCollectionViewCell: UICollectionViewCell {
    private lazy var primaryLabel: UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.numberOfLines = 1
        primaryLabel.setupFont(size: 14, weight: .bold)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        primaryLabel.isSkeletonable = true
        return primaryLabel
    }()
    
    private lazy var secondaryLabel: UILabel = {
        let secondaryLabel = UILabel()
        secondaryLabel.numberOfLines = 1
        secondaryLabel.setupFont(size: 13, weight: .medium)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        secondaryLabel.isSkeletonable = true
        return secondaryLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(primaryLabel)
        stackView.addArrangedSubview(secondaryLabel)
        
        isSkeletonable = true
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        let stackViewConstraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
        
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
        self.hideSkeleton()
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: primaryLabel.font ?? UIFont.systemFont(ofSize: 14, weight: .bold),
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
