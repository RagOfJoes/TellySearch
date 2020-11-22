//
//  HorizontalCollectionView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/20/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

public class HorizontalCollectionView: UIView {
    // MARK: - Internal Properties
    private let type: T.CellType!
    private var heightConstraint: NSLayoutConstraint!
    private var collectionViewHeight: NSLayoutConstraint!
    
    private lazy var header: CollectionViewHeader = {
        let header = CollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.isSkeletonable = true
        return header
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: T.Spacing.Horizontal(size: .small))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Only Register the Cell's that are required
        if type == .Featured {
            collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
        } else if type == .RegularSecondary {
            collectionView.register(RegularCell2.self, forCellWithReuseIdentifier: RegularCell2.reuseIdentifier)
        } else {
            collectionView.register(RegularCell.self, forCellWithReuseIdentifier: RegularCell.reuseIdentifier)            
        }
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return collectionView
        }
        flowLayout.itemSize = CGSize(width: T.Width.Cell(type: type), height: floor(T.Height.Cell(type: type)))
        
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init(_ type: T.CellType) {
        self.type = type
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(collectionView)
        
        setupAnchors()
        isSkeletonable = true
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateHeightConstraint()
        // Update immediately after setting
        // new itemSize
        collectionView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews Setup
extension HorizontalCollectionView {
    public func setupHeader(title: String, color: UIColor? = UIColor(named: "primaryTextColor")) {
        header.configure(title, color: color)
    }
}

// MARK: - Constraints
extension HorizontalCollectionView {
    private func updateHeightConstraint() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let oldHeight = heightConstraint.constant
        let newHeight = T.Height.Cell(type: type)
        if floor(oldHeight) != floor(newHeight) {
            let heightConstant: CGFloat = type == .Featured ? -100 : 35
            
            heightConstraint.constant = newHeight + heightConstant
            collectionViewHeight.constant = ceil(newHeight)
            flowLayout.itemSize = CGSize(width: T.Width.Cell(type: type), height: floor(newHeight))
        }
    }
    
    private func setupAnchors() {
        let heightConstant: CGFloat = type == .Featured ? -100 : 35
        let heightAnchorConstant: CGFloat = T.Height.Cell(type: type)
        heightConstraint = heightAnchor.constraint(equalToConstant: heightAnchorConstant + heightConstant)
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: heightAnchorConstant)
        NSLayoutConstraint.activate([
            heightConstraint,
            
            header.topAnchor.constraint(equalTo: topAnchor),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: T.Spacing.Horizontal()),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -T.Spacing.Horizontal()),
        ])
        
        var collectionViewLeading: NSLayoutConstraint!
        var collectionViewTrailing: NSLayoutConstraint!
        if #available(iOS 11, *) {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        } else {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        }
        let collectionViewConstraints: [NSLayoutConstraint] = [
            collectionViewHeight,
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: T.Spacing.Vertical(size: .small))
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalCollectionView: UICollectionViewDelegateFlowLayout { }

// MARK: - SkeletonCollectionViewDelegate
extension HorizontalCollectionView: SkeletonCollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if type == .Featured {
            return FeaturedCell.reuseIdentifier
        } else if type == .RegularSecondary {
            return RegularCell2.reuseIdentifier
        } else {
            return RegularCell.reuseIdentifier
        }
    }
}
