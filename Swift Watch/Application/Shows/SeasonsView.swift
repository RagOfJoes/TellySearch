//
//  SeasonsView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/25/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import SkeletonView

class SeasonsView: UICollectionViewController {
    // MARK: - Internal Properties
    let tvId: Int
    let season: Season
    let colors: UIImageColors
    var detail: SeasonDetail? = nil
    
    weak var creditModalDelegate: CreditDetailModalDelegate?
    
    // MARK: - Life Cycle
    init(tvId: Int, season: Season, colors: UIImageColors) {
        self.tvId = tvId
        self.season = season
        self.colors = colors
        
        let layout = CollectionViewLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = T.Spacing.Vertical(size: .large)
        
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup View
        setupNav()
        view.backgroundColor = colors.background
        // Setup CollectionView
        setupCollectionView()
        // Call Data Fetcher
        fetchDetails()
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
        navigationController?.navigationBar.backgroundColor = colors.background
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.tintColor = colors.primary
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.title = season.name
        navigationItem.rightBarButtonItem = backBarButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.primary!]
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.register(SeasonsViewCell.self, forCellWithReuseIdentifier: SeasonsViewCell.reuseIdentifier)
        collectionView.register(SeasonsViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewHeader.reuseIdentifier)
        collectionView.isSkeletonable = true
        collectionView.showAnimatedGradientSkeleton()
    }
}

// MARK: - Data Fetches
extension SeasonsView {
    private func fetchDetails() {
        season.fetchDetail(tvId: tvId).then { (data) in
            return SeasonDetail.decodeSeasonData(data: data)
        }.then { [weak self] (detail) in
            self?.detail = detail
            self?.collectionView.hideSkeleton()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SeasonsView {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = detail?.episodes?[indexPath.item] else { return }
        let episodeVC = EpisodeView(episode: episode, colors: colors)
        episodeVC.setCastViewDelegate(self)
        navigationController?.pushViewController(episodeVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewHeader.reuseIdentifier, for: indexPath) as? SeasonsViewHeader else {
            return UICollectionReusableView()
        }
        
        var overview = "-"
        var airDate = season.airDate?.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
            return "\(month) \(day), \(year)"
        }) ?? "-"
        
        if let safeOverview = season.overview {
            if safeOverview.count > 0 {
                overview = safeOverview
            }
        }
        
        if let episodes = detail?.episodes, episodes.count > 1 {
            if let startDate = episodes[0].airDate, let endDate = episodes[episodes.count - 1].airDate {
                let formatStartDate = startDate.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
                    return "\(month) \(day), \(year)"
                }) ?? "-"
                let formatEndDate = endDate.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
                    return "\(month) \(day), \(year)"
                }) ?? "-"
                
                airDate = "\(formatStartDate) - \(formatEndDate)"
            }
        }
        headerView.setCastViewDelegate(self)
        headerView.configure(airDate: airDate, overview: overview, episodes: detail?.episodes?.count, credits: detail?.credits, colors: colors)
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
        let marginBottom: CGFloat = T.Spacing.Vertical(size: .large) * 3
                
        let titleHeight = "".height(withConstrainedWidth: width, font: T.Typography(variant: .Title).font)
        if detail != nil, let overview = season.overview {
            if overview.count > 0 {
                overviewLabel = overview
            }
        }
        let titlesHeight = titleHeight * 4
        let castViewHeight = T.Height.Cell(type: .RegularSecondary)
        let episodesHeight: CGFloat = 30 + T.Spacing.Vertical(size: .small)
        let airDateHeight = "".height(withConstrainedWidth: width, font: T.Typography(variant: .Body).font)
        let overviewHeight = overviewLabel.height(withConstrainedWidth: width, font: T.Typography(variant: .Body).font) + 2
        
        var height = episodesHeight + marginBottom + titlesHeight + airDateHeight + overviewHeight + castViewHeight
        if let detail = detail, let credits = detail.credits, let cast = credits.cast, cast.count <= 0 {
            height -= castViewHeight + marginBottom - episodesHeight
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension SeasonsView: SkeletonCollectionViewDataSource {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let episodes = detail?.episodes {
            return episodes.count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonsViewCell.reuseIdentifier, for: indexPath) as? SeasonsViewCell else {
            return UICollectionViewCell()
        }
        
        if let episodes = detail?.episodes {
            let episode = episodes[indexPath.item]
            let name = "\(indexPath.item + 1). \(episode.name)"
            let url = episode.backdrop != nil ? K.URL.Backdrop + episode.backdrop! : nil
            
            cell.configure(url: url, name: name, airDate: episode.airDate, colors: colors)
        }
        
        return cell
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        SeasonsViewHeader.reuseIdentifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SeasonsViewCell.reuseIdentifier
    }
}

// MARK: - CastCollectionViewDelegate
extension SeasonsView: CastCollectionViewDelegate {
    func select(cast: Cast) {
        let creditModal = CreditDetailModal(with: cast, using: colors)
        creditModal.delegate = creditModalDelegate
        navigationController?.pushViewController(creditModal, animated: true)
    }
}

