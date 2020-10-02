//
//  SeasonsViewCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/29/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class SeasonsViewCell: UICollectionViewCell {
    // MARK: - Internal Properties
    static let height: CGFloat = SeasonsViewCell.backdropHeight + ("".height(withConstrainedWidth: SeasonsViewCell.backdropWidth, font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15, weight: .semibold))) * 2) + "".height(withConstrainedWidth: SeasonsViewCell.backdropWidth, font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))) + 5
    static let backdropWidth: CGFloat = UIScreen.main.bounds.width - 40
    static let backdropHeight: CGFloat = .getHeight(with: SeasonsViewCell.backdropWidth, using: (16 / 9))
    
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
        name.setupFont(size: 15, weight: .semibold)
        name.textColor = UIColor(named: "primaryTextColor")
        name.translatesAutoresizingMaskIntoConstraints = false
        
        return name
    }()
    
    private lazy var airDate: UILabel = {
        let airDate = UILabel()
        airDate.numberOfLines = 1
        airDate.setupFont(size: 13, weight: .medium)
        airDate.textColor = UIColor(named: "primaryTextColor")
        airDate.translatesAutoresizingMaskIntoConstraints = false
        
        return airDate
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(backdrop)
        contentView.addSubview(name)
        contentView.addSubview(airDate)
        
        isSkeletonable = true
        
        setupAnchors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
    private func setupAnchors() {
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            backdrop.heightAnchor.constraint(equalToConstant: SeasonsViewCell.backdropHeight)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let nameConstraints: [NSLayoutConstraint] = [
            name.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            name.topAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: 5),
        ]
        NSLayoutConstraint.activate(nameConstraints)
        
        let airDateConstraints: [NSLayoutConstraint] = [
            airDate.topAnchor.constraint(equalTo: name.bottomAnchor),
            airDate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            airDate.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
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
