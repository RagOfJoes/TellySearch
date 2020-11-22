//
//  SeasonsView.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/25/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView
import OctreePalette

class SeasonsView: UICollectionViewController {
    // MARK: - Internal Properties
    private let tvId: Int
    private let season: Season
    private let colors: ColorTheme
    private var detail: SeasonDetail? = nil
    
    weak var creditVCDelegate: CreditDetailDelegate?
    
    // MARK: - Life Cycle
    init(tvId: Int, season: Season, colors: ColorTheme) {
        self.tvId = tvId
        self.season = season
        self.colors = colors
        
        let layout = CollectionViewLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = T.Spacing.Vertical(size: .large)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup View
        setupNav()
        view.backgroundColor = colors.background.uiColor
        
        // Setup CollectionView
        setupCollectionView()
        // Setup Skeleton
        view.isSkeletonable = true
        view.showAnimatedSkeleton()
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
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: colors.background.uiColor), for: .default)
        
        navigationController?.navigationBar.tintColor = colors.primary.uiColor
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.title = season.name
        navigationItem.rightBarButtonItem = backBarButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.primary.uiColor]
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(SeasonsViewCell.self, forCellWithReuseIdentifier: SeasonsViewCell.reuseIdentifier)
        collectionView.register(SeasonsViewCastCell.self, forCellWithReuseIdentifier: SeasonsViewCastCell.reuseIdentifier)
        collectionView.register(SeasonsViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewHeader.reuseIdentifier)
        collectionView.register(SeasonsViewCastHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewCastHeader.reuseIdentifier)
        
        // Empty Headers
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SeasonsViewNoopHeader")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SeasonsViewNoopFooter")
        
        collectionView.isSkeletonable = true
    }
}

// MARK: - Data Fetches
extension SeasonsView {
    private func fetchDetails() {
        let request: Promise<SeasonDetail> = NetworkManager.request(endpoint: ShowEndpoint.getSeasonDetail(tvId: tvId, seasonNumber: season.seasonNumber), cache: C.Season, cacheKey: season.cacheKey)
        request.then { [weak self] (detail) in
            self?.detail = detail
            
            DispatchQueue.main.async {
                self?.view.hideSkeleton()
            }
        }.catch { e in
            print(e)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SeasonsView {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 1 {
            guard let episode = detail?.episodes?[indexPath.item] else { return }
            let episodeVC = EpisodeView(episode: episode, colors: colors)
            episodeVC.guestStarsDelegate = self
            navigationController?.pushViewController(episodeVC, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        if kind == UICollectionView.elementKindSectionHeader {
            if section == 0 {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewHeader.reuseIdentifier, for: indexPath) as? SeasonsViewHeader else {
                    return UICollectionReusableView()
                }
                
                var overview = "-"
                 let airDate = season.airDate?.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
                    return "\(month) \(day), \(year)"
                }) ?? "-"
                
                if let safeOverview = season.overview {
                    if safeOverview.count > 0 {
                        overview = safeOverview
                    }
                }
                
                headerView.configure(airDate: airDate, overview: overview, colors: colors)
                return headerView
            } else {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SeasonsViewCastHeader.reuseIdentifier, for: indexPath) as? SeasonsViewCastHeader else {
                    return UICollectionReusableView()
                }
                headerView.configure(count: detail?.episodes?.count, colors: colors)
                return headerView
            }
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "SeasonsViewNoopFooter", for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SeasonsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        let height: CGFloat
        
        if section == 0 {
            height = floor(T.Height.Cell(type: .RegularSecondary))
        } else {
            height = floor(T.Height.Season)
        }
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width - (T.Spacing.Horizontal() * 2)
        if section == 0 {
            var overviewLabel: String = "-"
            let marginBottom: CGFloat = T.Spacing.Vertical(size: .large) * 2
            
            let titleHeight = "".height(withConstrainedWidth: width, font: T.Typography(variant: .Title).font)
            if detail != nil, let overview = season.overview {
                if overview.count > 0 {
                    overviewLabel = overview
                }
            }
            let titlesHeight = titleHeight * 2
            let airDateHeight = "".height(withConstrainedWidth: width, font: T.Typography(variant: .Body).font)
            let overviewHeight = overviewLabel.height(withConstrainedWidth: width, font: T.Typography(variant: .Body).font) + T.Spacing.Vertical(size: .small)
            
            var height = marginBottom + titlesHeight + airDateHeight + overviewHeight
            if let detail = detail, let credits = detail.credits, let cast = credits.cast, cast.count <= 0 {
                height -= marginBottom - T.Spacing.Vertical(size: .small)
            }
            return CGSize(width: width, height: height)
        } else {
            let titleHeight: CGFloat = 30
            let height: CGFloat = titleHeight + T.Spacing.Vertical(size: .small)
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: K.ScrollOffsetHeight)
    }
}

// MARK: - SkeletonCollectionViewDataSource
extension SeasonsView: SkeletonCollectionViewDataSource {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let episodes = detail?.episodes {
                return episodes.count
            }
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        
        if section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonsViewCastCell.reuseIdentifier, for: indexPath) as? SeasonsViewCastCell else {
                return UICollectionViewCell()
            }
            
            if let credits = detail?.credits {
                cell.castViewDelegate = self
                cell.configure(credits: credits, colors: colors)
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonsViewCell.reuseIdentifier, for: indexPath) as? SeasonsViewCell else {
                return UICollectionViewCell()
            }
            
            if let episodes = detail?.episodes {
                let episode = episodes[indexPath.item]
                let name = "\(indexPath.item + 1). \(episode.name ?? "-")"
                let url = episode.backdrop != nil ? K.URL.Backdrop + episode.backdrop! : nil
                
                cell.configure(url: url, name: name, airDate: episode.airDate, colors: colors)
            }
            
            return cell
        }
    }
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        let section = indexPath.section
        if supplementaryViewIdentifierOfKind == UICollectionView.elementKindSectionHeader {
            if section == 0 {
                return SeasonsViewHeader.reuseIdentifier
            } else {
                return "SeasonsViewNoopHeader"
            }
        } else {
            return "SeasonsViewNoopFooter"
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        let section = indexPath.section
        
        if section == 0 {
            return SeasonsViewCastCell.reuseIdentifier
        } else {
            return SeasonsViewCell.reuseIdentifier
        }
    }
}

// MARK: - CastCollectionViewDelegate
extension SeasonsView: CastCollectionViewDelegate {
    func select(cast: Cast) {
        let creditVC = CreditDetailViewController(with: cast, using: colors)
        creditVC.delegate = creditVCDelegate
        navigationController?.pushViewController(creditVC, animated: true)
    }
}

