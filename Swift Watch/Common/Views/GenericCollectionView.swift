//
//  GenericCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/20/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

public class GenericCollectionView: UIView {
    // MARK: - Internal Properties
    private let type: T.CellType!
    
    private lazy var header: GenericCollectionViewHeader = {
        let header = GenericCollectionViewHeader()
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
        } else {
            collectionView.register(RegularCell.self, forCellWithReuseIdentifier: RegularCell.reuseIdentifier)
        }
        
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
        collectionView.prepareSkeleton { (done) in
            self.showAnimatedGradientSkeleton()
        }
    }
    
    public func setupHeader(title: String, color: UIColor? = UIColor(named: "primaryTextColor")) {
        header.configure(title, color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Constraints
extension GenericCollectionView {
    private func setupAnchors() {
        let heightConstant: CGFloat = type == .Featured ? -100 : 35
        let heightConstraint: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: T.Height.Cell(type: type) + heightConstant)
        NSLayoutConstraint.activate([
            heightConstraint,
            
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 30),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: T.Spacing.Horizontal()),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -T.Spacing.Horizontal()),
        ])
        
        var collectionViewLeading: NSLayoutConstraint!
        var collectionViewTrailing: NSLayoutConstraint!
        let collectionViewHeight: NSLayoutConstraint = collectionView.heightAnchor.constraint(equalToConstant: T.Height.Cell(type: type))
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
extension GenericCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = T.Width.Cell(type: .Regular)
        
        if type == .Featured {
            width = T.Width.Cell(type: .Featured)
        }
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

// MARK: - SkeletonCollectionViewDelegate
extension GenericCollectionView: SkeletonCollectionViewDataSource {
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
        } else {
            return RegularCell.reuseIdentifier
        }
    }
}
