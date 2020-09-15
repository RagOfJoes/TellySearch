//
//  CastCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/7/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol CastCollectionViewDelegate: class {
    func select(cast: Cast)
}

class CastCollectionView: UIView {
    var credits: Credits?
    var colors: UIImageColors?
    weak var delegate: CastCollectionViewDelegate?
    
    lazy var header: CastCollectionViewHeader = {
        let header = CastCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.isSkeletonable = true
        
        return header
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OverviewCell.self, forCellWithReuseIdentifier: OverviewCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(header)
        addSubview(collectionView)
        isSkeletonable = true
        collectionView.prepareSkeleton { (done) in
            self.showAnimatedGradientSkeleton()
        }
        setupAnchors()
    }
    
    func configure(with credits: Credits, title: String = "Cast", and colors: UIImageColors) {
        self.credits = credits
        self.colors = colors
        
        header.configure(with: title)
        header.title.textColor = self.colors?.primary
        
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension CastCollectionView {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary + 32),
            
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
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2),
            collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension CastCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cast = credits?.cast?[indexPath.row] {
            self.delegate?.select(cast: cast)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: K.Poster.width, height: collectionView.frame.height)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
        
        if let cast = credits?.cast?[indexPath.row], let safeColors = colors {
            guard let profile = cast.profilePath else {
                cell.configure(primary: cast.name, secondary: cast.character)
                return cell
            }
            cell.configure(primary: cast.name, secondary: cast.character, image: K.Credits.profileURL + profile, colors: safeColors)
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension CastCollectionView: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
}
