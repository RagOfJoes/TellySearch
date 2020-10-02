//
//  GenericCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/20/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

enum GenericCollectionViewType {
    case Featured
    
    case Regular
    case RegularHasSecondary
}

class GenericCollectionView: UIView {
    // MARK: - Internal Properties
    private let type: GenericCollectionViewType!
    
    private lazy var header: GenericCollectionViewHeader = {
        let header = GenericCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.isSkeletonable = true
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 10)
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
    init(_ type: GenericCollectionViewType) {
        self.type = type
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(collectionView)
        
        setupAnchors()
        isSkeletonable = true
        
        collectionView.prepareSkeleton { [weak self] (done) in
            self?.showAnimatedGradientSkeleton()
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
        var heightConstraint: NSLayoutConstraint!
        var collectionViewHeight: NSLayoutConstraint!
        
        let regularHeightConstraint = heightAnchor.constraint(equalToConstant: K.Overview.regularHeight + 35)
        let regularHeightSecondaryConstraint = heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary + 35)
        let featuredHeightConstraint = heightAnchor.constraint(equalToConstant: K.Overview.featuredCellHeight - 100)
        
        switch type {
        case .Featured:
            heightConstraint = featuredHeightConstraint
            collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: K.Overview.featuredCellHeight)
            break
        case .RegularHasSecondary:
            heightConstraint = regularHeightSecondaryConstraint
            collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary)
            break
        default:
            heightConstraint = regularHeightConstraint
            collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeight)
            break
        }
        
        NSLayoutConstraint.activate([
            heightConstraint,
            
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 30),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
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
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

extension GenericCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = K.Poster.width
        
        if type == .Featured {
            width = K.Overview.featuredCellWidth
        }
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

// MARK: - SkeletonCollectionViewDelegate
extension GenericCollectionView: SkeletonCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if type == .Featured {
            return FeaturedCell.reuseIdentifier
        } else {
            return RegularCell.reuseIdentifier
        }
    }
}
