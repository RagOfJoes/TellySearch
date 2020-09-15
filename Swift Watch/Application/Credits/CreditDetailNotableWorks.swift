//
//  CreditDetailNotableWorks.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/31/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol CreditDetailNotableWorksDelegate: class {
    func select(media: Media)
}

class CreditDetailNotableWorks: UIView {
    var media: [Media]?
    let colors: UIImageColors
    
    weak var delegate: CreditDetailNotableWorksDelegate?
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.setupFont(size: 14, weight: .bold)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.isSkeletonable = true
        header.skeletonCornerRadius = 5
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.createHorizontalCollectionView(minimumLineSpacing: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OverviewCell.self, forCellWithReuseIdentifier: OverviewCell.reuseIdentifier)
        return collectionView
    }()
    
    init(colors: UIImageColors) {
        self.colors = colors
        super.init(frame: .zero)
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
    
    func configure(with media: [Media]) {
        self.media = media
        DispatchQueue.main.async {
            self.header.text = "Notable Works"
            self.header.textColor = self.colors.primary
        }
        
        if media.count <= 0 {
            collectionView.removeFromSuperview()
        }
        
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helper Functions
extension CreditDetailNotableWorks {
    private func setupAnchors() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary + 30),
            
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 25),
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
        let collectionViewConstraints: [NSLayoutConstraint] = [
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 5),
            collectionView.heightAnchor.constraint(equalToConstant: K.Overview.regularHeightWithSecondary)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension CreditDetailNotableWorks: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let safeMedia = media?[indexPath.item] {
            self.delegate?.select(media: safeMedia)
        }
    }
}

extension CreditDetailNotableWorks: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: K.Poster.width, height: collectionView.frame.height)
    }
}

// MARK: - UICollectionViewDataSource
extension CreditDetailNotableWorks: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let safeWorks = self.media else { return 0 }
        
        return safeWorks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
        
        if let media = self.media?[indexPath.row] {
            if let mediaType = media.mediaType {
                var textStr: String
                if mediaType == .movie {
                    textStr = media.title!
                } else {
                    textStr = media.name!
                }

                if let safePoster = media.posterPath {
                    cell.configure(primary: textStr, secondary: media.character ?? media.job!, image: K.Poster.URL + safePoster, colors: self.colors)
                } else {
                    cell.configure(primary: textStr, secondary: media.character ?? media.job!, colors: self.colors)
                }
            }
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension CreditDetailNotableWorks: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return OverviewCell.reuseIdentifier
    }
}


