//
//  CVTCell.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/21/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

enum CVTCellType {
    case Regular
    case Featured
}

class CVTCell: UITableViewCell {
    static var reuseIdentifier: String {
        get {
            return String(describing: self)
        }
    }
    
    // MARK: - Internal Properties
    private var type: CVTCellType!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 20)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(RegularCell.self, forCellWithReuseIdentifier: RegularCell.reuseIdentifier)
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
        
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: CVTCell.reuseIdentifier)
        clipsToBounds = true
        backgroundColor = .clear
        
        contentView.addSubview(collectionView)
        
        setupAnchors()
        isSkeletonable = true
        
        collectionView.prepareSkeleton { [weak self] (done) in
            self?.showAnimatedGradientSkeleton()
        }
    }
    
    public func configure(_ type: CVTCellType) {
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension CVTCell {
    private func setupAnchors() {
        var collectionViewHeight: NSLayoutConstraint!
        var collectionViewLeading: NSLayoutConstraint!
        var collectionViewTrailing: NSLayoutConstraint!
        
        if #available(iOS 11, *) {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        } else {
            collectionViewLeading = collectionView.leadingAnchor.constraint(equalTo: leadingAnchor)
            collectionViewTrailing = collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        }
        
        if type == .Featured {
            collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: K.Overview.featuredCellHeight)
        } else {
            collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeight)
        }
        
        let collectionViewConstraints: [NSLayoutConstraint] = [
            collectionViewHeight,
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.topAnchor.constraint(equalTo: topAnchor),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

extension CVTCell: SkeletonCollectionViewDataSource {
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

// MARK: - UICollectionViewLayout
extension CVTCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = K.Poster.width
        
        if type == .Featured {
            width = K.Overview.featuredCellWidth
        }
        
        return CGSize(width: width, height: collectionView.frame.height)
    }
}
