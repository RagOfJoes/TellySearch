//
//  CastCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class CastCollectionView: UIView {
    var credits: Credits?
    var colors: UIImageColors?
    
    static var collectionViewHeight: CGFloat = 235
    static var collectionViewCellWidth: CGFloat = 135
    
    lazy var header: CastCollectionViewHeader = {
        let header = CastCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        DispatchQueue.main.async {
            header.isSkeletonable = true
            header.skeletonCornerRadius = 5
            header.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))            
        }
        
        return header
    }()
    
    lazy var collectionView: UICollectionView = {
        // Setup Layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        
        // Setup CollectionView
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
                
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        DispatchQueue.main.async {
            collectionView.isSkeletonable = true
            collectionView.skeletonCornerRadius = 5
            collectionView.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        }
        
        collectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(collectionView)
        setupAnchors()
    }
    
    func configure(with _credits: Credits, _colors: UIImageColors) {
        self.credits = _credits
        self.colors = _colors
        
        header.configure(with: "Top Billed Cast")
        header.title.textColor = colors?.primary
                
        collectionView.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension CastCollectionView {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 30),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            collectionView.heightAnchor.constraint(equalToConstant: CastCollectionView.collectionViewHeight),
        ])
    }
}

// MARK: - UICollectionViewDelegate
extension CastCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CastCollectionView.collectionViewCellWidth, height: CastCollectionView.collectionViewHeight)
    }
}

// MARK: - UICollectionViewDataSource
extension CastCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let castLen = credits?.cast?.count {
            if castLen >= 10 {
                return 10
            } else if castLen > 0 && castLen < 10 {
                return castLen
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.reuseIdentifier, for: indexPath) as! CastCollectionViewCell
        
        if let cast = credits?.cast?[indexPath.row], let safeColors = colors{
            cell.configure(with: cast, colors: safeColors)
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension CastCollectionView: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CastCollectionViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}
