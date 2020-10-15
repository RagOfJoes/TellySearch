//
//  CreatorsCollectionView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/11/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

protocol CreatorsCollectionVIewDelegate: class {
    func select(crew: Crew)
}

class CreatorsCollectionView: UIView {
    // MARK: - Internal Properties
    private var crews: [Crew]?
    private var colors: UIImageColors?
    private var heightConstraint: NSLayoutConstraint!
    weak var delegate: CreatorsCollectionVIewDelegate?
    
    private lazy var header: CollectionViewHeader = {
        let header = CollectionViewHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.isSkeletonable = true
        return header
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: T.Spacing.Horizontal(), bottom: 0, right: T.Spacing.Horizontal())
        
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
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.isSkeletonable = true        
        return collectionView
    }()
    
    private let heightConstant: CGFloat = {
        let placeholderText = "Lorem"
        let secondaryFont = T.Typography(variant: .Subtitle).font
        let primaryFont = T.Typography(variant: .Body, weight: .bold).font
        let heightConstant: CGFloat = placeholderText.height(font: primaryFont) + placeholderText.height(font: secondaryFont)
        return heightConstant
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: heightConstant + 40)
        
        addSubview(header)
        addSubview(collectionView)
        isSkeletonable = true
        setupAnchors()
    }
    
    func configure(with crews: [Crew], colors: UIImageColors, and title: String = "Created By") {
        self.crews = crews
        self.colors = colors
        
        header.configure(title, color: colors.primary)
        
        if crews.count > 2 {
            let numOfRows: CGFloat = (CGFloat(crews.count) / 2).rounded(.toNearestOrEven)
            
            if numOfRows > 4 {
                heightConstraint.constant = heightConstant * 4
            } else {
                heightConstraint.constant = heightConstant * numOfRows
            }
        }
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
            collectionViewLeading,
            collectionViewTrailing,
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, constant: -35),
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: T.Spacing.Vertical(size: .small)),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - UICollectionViewDelegate
extension CreatorsCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let crew = crews?[indexPath.row] else { return }
        delegate?.select(crew: crew)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - T.Spacing.Horizontal() * 2, height: heightConstant)
    }
}

// MARK: - UICollectionViewDataSource
extension CreatorsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let crewsLen = crews?.count {
            return crewsLen > 4 ? 4 : crewsLen
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreatorsCollectionViewCell.reuseIdentifier, for: indexPath) as! CreatorsCollectionViewCell
        
        if let crew = crews?[indexPath.row], let safeColors = colors {
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
