//
//  SeasonsView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/25/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class SeasonsView: UIViewController {
    // MARK: - Internal Properties
    let tvId: Int
    let season: Season
    let colors: UIImageColors
    var detail: SeasonDetail? = nil
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewLayout()
        layout.minimumLineSpacing = 35
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.bounces = true
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SeasonsViewCell.self, forCellWithReuseIdentifier: SeasonsViewCell.reuseIdentifier)
        collectionView.register(SeasonsOverviewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsOverviewCell.reuseIdentifier)
        
        collectionView.isSkeletonable = true
        return collectionView
    }()
    
    // MARK: - Life Cycle
    init(tvId: Int, season: Season, colors: UIImageColors) {
        self.tvId = tvId
        self.season = season
        self.colors = colors
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        view.isSkeletonable = true
        view.backgroundColor = colors.background
        
        view.addSubview(collectionView)
        
        collectionView.prepareSkeleton { done in
            self.view.showAnimatedGradientSkeleton()
        }
        
        setupAnchors()
        
        fetchDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup
extension SeasonsView {
    @objc func onBackButton() {
        dismiss(animated: true)
    }
    
    private func setupNav() {        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: colors.background), for: .default)
        
        navigationController?.navigationBar.tintColor = colors.primary
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.title = season.name
        navigationItem.rightBarButtonItem = backBarButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.primary!]
    }
    
    private func setupAnchors() {
        let collectionViewConstraints: [NSLayoutConstraint] = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
}

// MARK: - Subviews Setup
extension SeasonsView {
}

// MARK: - Data Fetches
extension SeasonsView {
    private func fetchDetails() {
        season.fetchDetail(tvId: tvId).then { (data) in
            return SeasonDetail.decodeSeasonData(data: data)
        }.then { [weak self] (detail) in
            self?.detail = detail
            
            DispatchQueue.main.async {
                self?.view.hideSkeleton()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SeasonsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsOverviewCell.reuseIdentifier, for: indexPath) as? SeasonsOverviewCell else {
            return UICollectionReusableView()
        }
        
        var value = "-"
        
        if let overview = season.overview {
            if overview.count > 0 {
                value = overview
            }
        }
        headerView.configure(airDate: season.airDate, overview: value, colors: colors)
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SeasonsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: SeasonsViewCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width - 40
        
        var overviewLabel: String = "-"
        let marginBottom: CGFloat = 35
        let lineSpacing: CGFloat = 15
        
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let valueFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        let titleHeight = "".height(withConstrainedWidth: width, font: titleFont) * 2
        
        if let overview = season.overview {
            if overview.count > 0 {
                overviewLabel = overview
            }
        }
        let airDateHeight = "".height(withConstrainedWidth: width, font: valueFont)
        let overviewHeight = overviewLabel.height(withConstrainedWidth: width, font: valueFont) + 2
        
        let height = marginBottom + lineSpacing + titleHeight + airDateHeight + overviewHeight
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension SeasonsView: SkeletonCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let episodes = detail?.episodes {
            return episodes.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonsViewCell.reuseIdentifier, for: indexPath) as? SeasonsViewCell else {
            return UICollectionViewCell()
        }
        
        if let episodes = detail?.episodes {
            let episode = episodes[indexPath.item]
            let name = "\(indexPath.item + 1). \(episode.name)"
            let url = episode.backdrop != nil ? K.Backdrop.URL + episode.backdrop! : nil
            
            cell.configure(url: url, name: name, airDate: episode.airDate, colors: colors)
        }
        
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        SeasonsOverviewCell.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SeasonsViewCell.reuseIdentifier
    }
}
