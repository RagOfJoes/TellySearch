//
//  SeasonsViewCell.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class SeasonsViewCell: UICollectionViewCell {
    // MARK: - Internal Properties
    private lazy var backdrop: UIImageView = {
        let backdrop = UIImageView()
        backdrop.clipsToBounds = true
        backdrop.contentMode = .scaleAspectFill
        backdrop.roundCorners(.allCorners, radius: 5)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        backdrop.isSkeletonable = true
        backdrop.skeletonCornerRadius = 5
        return backdrop
    }()
    
    private lazy var name: UILabel = {
        let name = UILabel()
        name.numberOfLines = 2
        name.textColor = UIColor(named: "primaryTextColor")
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = T.Typography(variant: .Body, weight: .bold).font
        
        return name
    }()
    
    private lazy var airDate: UILabel = {
        let airDate = UILabel()
        airDate.numberOfLines = 1
        airDate.font = T.Typography(variant: .Subtitle).font
        airDate.textColor = UIColor(named: "primaryTextColor")
        airDate.translatesAutoresizingMaskIntoConstraints = false
        
        return airDate
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backdrop)
        contentView.addSubview(name)
        contentView.addSubview(airDate)
                
        isSkeletonable = true
        setupAnchors()
    }
    
    override var isHighlighted: Bool {
        didSet {
            return shrink(down: isHighlighted)            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View setup
extension SeasonsViewCell {
    private func getLabelHeight() -> CGFloat {
        let placeholder = ""
        let airDateFont = T.Typography(variant: .Subtitle).font
        let airDateHeight: CGFloat = placeholder.height(withConstrainedWidth: T.Width.Episode, font: airDateFont)
        
        let nameFont = T.Typography(variant: .Body, weight: .bold).font
        let nameHeight: CGFloat = placeholder.height(withConstrainedWidth: T.Width.Episode, font: nameFont) * 2
        
        return airDateHeight + nameHeight
    }
    
    private func setupAnchors() {
        let contentViewConstraints: [NSLayoutConstraint] = [
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(contentViewConstraints)
        
        let labelHeight = getLabelHeight()
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdrop.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -labelHeight),
            backdrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: T.Spacing.Horizontal()),
            backdrop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let nameConstraints: [NSLayoutConstraint] = [
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: T.Spacing.Horizontal()),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -T.Spacing.Horizontal()),
            name.topAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: T.Spacing.Vertical(size: .small)),
        ]
        NSLayoutConstraint.activate(nameConstraints)
        
        let airDateConstraints: [NSLayoutConstraint] = [
            airDate.topAnchor.constraint(equalTo: name.bottomAnchor),
            airDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: T.Spacing.Horizontal()),
            airDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(airDateConstraints)
    }
}

// MARK: - Subviews setup
extension SeasonsViewCell {
    func configure(url: String? = nil, name: String, airDate: String? = "-", colors: UIImageColors? = nil) {
        let placeholder = UIImage(named: "placeholderBackdrop")
        
        if let urlString = url {
            let validURL = URL(string: urlString)
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            backdrop.kfSetImage(with: validURL, using: placeholder, options: options)
        } else {
            backdrop.image = placeholder
        }
        
        self.name.text = name
        setupAirDate(date: airDate)
        
        guard let safeColors = colors else { return }
        setupColors(colors: safeColors)
    }
    
    private func setupAirDate(date: String?) {
        if date != nil {
            let dateStr = date!.formatDate(format: "YYYY-MM-dd") { (month, day, year) -> String in
                return "\(month) \(day), \(year)"
            }
            
            airDate.text = dateStr ?? "-"
        } else {
            airDate.text = "-"
        }
    }
    
    private func setupColors(colors: UIImageColors) {
        name.textColor = colors.primary
        airDate.textColor = colors.secondary
    }
}

// MARK: - Reusable Cell
extension SeasonsViewCell: ReusableCell { }
