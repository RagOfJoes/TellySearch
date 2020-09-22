//
//  CreatorsCollectionView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class CreatorsCollectionView: UIView {
    private var crews: [Crew]?
    private var colors: UIImageColors?
    private var heightConstraint: NSLayoutConstraint!
    
    private lazy var header: GenericCollectionViewHeader = {
        let header = GenericCollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.isSkeletonable = true
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CreatorsCollectionViewCell.self, forCellWithReuseIdentifier: CreatorsCollectionViewCell.reuseIdentifier)
        
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.isSkeletonable = true
        collectionView.skeletonCornerRadius = 5
        
        return collectionView
    }()
    
    let heightConstant: CGFloat = {
        let placeholderText = "Lorem"
        let primaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        let secondaryFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 13, weight: .medium))
        let heightConstant: CGFloat = placeholderText.height(font: primaryFont) + placeholderText.height(font: secondaryFont)
        return heightConstant
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        self.heightConstraint = heightAnchor.constraint(equalToConstant: self.heightConstant + 40)
        
        addSubview(header)
        addSubview(collectionView)
        isSkeletonable = true
        collectionView.prepareSkeleton { (done) in
            self.showAnimatedGradientSkeleton()
        }
        setupAnchors()
    }
    
    func configure(with crews: [Crew], colors: UIImageColors, and title: String = "Created By") {
        self.crews = crews
        self.colors = colors
        
        self.header.configure(title, color: colors.primary)
        
        if crews.count > 2 {
            let numOfRows: CGFloat = (CGFloat(crews.count) / 2).rounded(.toNearestOrEven)
            self.heightConstraint.constant = self.heightConstant * numOfRows + 45
        }
        
        self.hideSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CreatorsCollectionView {
    private func setupAnchors() {
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
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, constant: -35),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension CreatorsCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.crews?[indexPath.row]) != nil {
            //            self.delegate?.select(cast: cast)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 40, height: self.heightConstant)
    }
}

// MARK: - UICollectionViewDataSource
extension CreatorsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let crewsLen = self.crews?.count {
            return crewsLen > 4 ? 4 : crewsLen
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreatorsCollectionViewCell.reuseIdentifier, for: indexPath) as! CreatorsCollectionViewCell
        
        if let crew = self.crews?[indexPath.row], let safeColors = colors {
            cell.configure(primary: crew.name, secondary: crew.job , color: safeColors.secondary)
        }
        
        return cell
    }
}


// MARK: - SkeletonCollectionViewDataSource
extension CreatorsCollectionView: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return CreatorsCollectionViewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}
