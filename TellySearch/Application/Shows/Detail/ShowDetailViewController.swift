//
//  ShowDetailViewController.swift
//  TellySearch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import OctreePalette

class ShowDetailViewController: UIViewController {
    // MARK: - Internal Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let show: Show
    private var detail: ShowDetail?
    private var colors: ColorTheme?
    
    private var containerView: UIView
    private var scrollView: UIScrollView
    private lazy var backdropDetail: BackdropDetail = {
        let backdropDetail = BackdropDetail()
        backdropDetail.delegate = self
        return backdropDetail
    }()
    
    private lazy var createdBy: CreatorsCollectionView = {
        let createdBy = CreatorsCollectionView()
        createdBy.delegate = self
        
        return createdBy
    }()
    
    private lazy var overviewStack: InfoStackView = {
        let overviewStack = InfoStackView()
        return overviewStack
    }()
    
    private lazy var seasonsView: ShowDetailSeasons = {
        let seasonsView = ShowDetailSeasons(.RegularSecondary)
        seasonsView.delegate = self
        return seasonsView
    }()
    
    private lazy var castCollectionView: CastCollectionView = {
        let castCollectionView = CastCollectionView(.RegularSecondary)
        castCollectionView.delegate = self
        return castCollectionView
    }()
    
    private lazy var recommendationsView: ShowDetailRecommendations = {
        let recommendationsView = ShowDetailRecommendations(.Regular)
        recommendationsView.delegate = self
        return recommendationsView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [seasonsView, castCollectionView, recommendationsView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.setCustomSpacing(T.Spacing.Vertical(size: .large), after: seasonsView)
        stackView.setCustomSpacing(T.Spacing.Vertical(size: .large), after: castCollectionView)
        stackView.setCustomSpacing(T.Spacing.Vertical(size: .large), after: recommendationsView)
        
        stackView.isSkeletonable = true
        return stackView
    }()
    
    // MARK: - Lifecycle
    init(with show: Show) {
        self.show = show
        
        let (sV, cV) = UIView.createScrollView()
        scrollView = sV
        containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBarButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(backdropDetail)
        containerView.addSubview(createdBy)
        containerView.addSubview(overviewStack)
        containerView.addSubview(stackView)
        
        setupAnchors()
        
        view.isSkeletonable = true
        scrollView.isSkeletonable = true
        containerView.isSkeletonable = true
        view.showAnimatedSkeleton()
        setupDetailUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav(by: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // When User leaves View
        // retain colors and ensure that we're
        // resetting Nav color to appropriate Color
        if let safeColors = colors {
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.navigationController?.navigationBar.tintColor = safeColors.primary.uiColor
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(isMovingFromParent) {
            setupNav(by: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup
extension ShowDetailViewController {
    private func setupUIColors(with colors: ColorTheme) {
        view.backgroundColor = colors.background.uiColor
        navigationController?.navigationBar.tintColor = colors.primary.uiColor
    }
    
    func setupNav(by disappearing: Bool) {
        if disappearing {
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        } else {
            navigationController?.navigationBar.shadowImage = nil
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            
            UIView.animate(withDuration: 0.25) {
                self.navigationController?.navigationBar.prefersLargeTitles = true
            }
        }
        guard let tbc = tabBarController as? TabBarController else { return }
        tbc.hideTabBar(hide: disappearing)
    }
    
    private func setupAnchors() {
        let scrollViewConstraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        let containerViewConstraints: [NSLayoutConstraint] = [
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        
        let backdropDetailConstraints: [NSLayoutConstraint] = [
            backdropDetail.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropDetail.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropDetailConstraints)
        
        let createdByConstraints: [NSLayoutConstraint] = [
            createdBy.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
            createdBy.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor),
            createdBy.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
        ]
        NSLayoutConstraint.activate(createdByConstraints)
        
        let overviewStackConstraints: [NSLayoutConstraint] = [
            overviewStack.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            overviewStack.topAnchor.constraint(equalTo: createdBy.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            overviewStack.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(overviewStackConstraints)
        
        var stackViewLeadingAnchor: NSLayoutConstraint!
        var stackViewTrailingAnhor: NSLayoutConstraint!
        if #available(iOS 11, *) {
            stackViewLeadingAnchor = stackView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor)
            stackViewTrailingAnhor = stackView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
        } else {
            stackViewLeadingAnchor = stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
            stackViewTrailingAnhor = stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        }
        let stackViewConstraints: [NSLayoutConstraint] = [
            stackViewLeadingAnchor,
            stackViewTrailingAnhor,
            stackView.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: T.Spacing.Vertical(size: .large))
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
    private func updateContentSize() {
        let offsetHeight:CGFloat = K.ScrollOffsetHeight
        let screen = UIApplication.shared.windows[0].bounds
        
        let stackViewY = stackView.frame.maxY + offsetHeight
        if stackViewY > screen.height {
            scrollView.contentSize = CGSize(width: screen.width, height: stackViewY)
        } else {
            scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
        }
    }
}

// MARK: - SubViews Setup
extension ShowDetailViewController {
    private func setupDetailUI() {
        let request: Promise<ShowDetail> = NetworkManager.request(endpoint: ShowEndpoint.getShowDetail(id: show.id), cache: C.Show, cacheKey: show.cacheKey)
        request.then { [weak self] (detail) in
            let backdropText = self?.setupBackdropText(with: detail)

            let (genres, runtime) = backdropText ?? ("-", "-")

            let title = self?.show.name
            let releaseDate = self?.show.firstAirDate
            let posterURL = self?.show.posterPath
            let backdropURL = self?.show.backdropPath != nil ? K.URL.Backdrop + (self!.show.backdropPath!) : nil

            // Return Void Promise to allow Recommendations to setup UI
            self?.backdropDetail.configure(backdropURL: backdropURL, posterURL: posterURL, title: title, genres: genres, runtime: runtime, releaseDate: releaseDate)
            self?.detail = detail
        }
    }
    
    private func setupCastCollectionView(with credits: Credits, using colors: ColorTheme) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.27) {
                self.colors = colors
                
                self.setupUIColors(with: colors)
            }
            self.overviewStack.setup(title: "Overview", value: self.show.overview, colors: colors)
        }
        
        if credits.cast == nil {
            stackView.removeArrangedSubview(castCollectionView)
            castCollectionView.removeFromSuperview()
            return
        } else if let safeCast = credits.cast {
            if safeCast.count <= 0 {
                stackView.removeArrangedSubview(castCollectionView)
                castCollectionView.removeFromSuperview()
                return
            }
        }
        castCollectionView.configure(with: credits, title: "Series Cast", colors: colors)
    }
    
    private func setupSeasonsView(with seasons: [Season], using colors: ColorTheme) {
        if seasons.count <= 0 {
            stackView.removeArrangedSubview(seasonsView)
            seasonsView.removeFromSuperview()
            return
        }
        seasonsView.configure(with: seasons.reversed(), colors: colors)
    }
    
    private func setupRecommendationsView(with shows: [Show], using colors: ColorTheme) {
        if shows.count <= 0 {
            stackView.removeArrangedSubview(recommendationsView)
            recommendationsView.removeFromSuperview()
            return
        }
        recommendationsView.configure(with: shows, colors: colors)
    }
    
    private func setupBackdropText(with detail: ShowDetail) -> (String?, String?) {
        var genresStr: String?
        var runtimeStr: String?
        if let safeGenres = detail.genres {
            let genresArr = safeGenres.map { (genre) -> String in
                return genre.name
            }
            
            genresStr = genresArr.joined(separator: ", ")
        }
        
        if detail.episodeRunTime.count > 0, let safeRuntime = detail.episodeRunTime[0] {
            if safeRuntime > 0 {
                let (hours, minutes) = safeRuntime.minutesToHoursMinutes(minutes: safeRuntime)
                
                var runtimeHours: String = ""
                var runtimeMinutes: String = ""
                
                if hours == 1 {
                    runtimeHours = "\(hours) hr "
                } else if hours >= 1 {
                    runtimeHours = "\(hours) hrs "
                }
                
                if minutes == 1 {
                    runtimeMinutes = "\(minutes) min"
                } else if minutes >= 1 {
                    runtimeMinutes = "\(minutes) mins"
                }
                runtimeStr = "\(runtimeHours)\(runtimeMinutes)"
            }
        }
        
        return (genresStr, runtimeStr)
    }
}

extension ShowDetailViewController: BackdropDetailDelegate {
    func didSetupUI(colors: ColorTheme) {
        DispatchQueue.main.async {
            if let seasons = self.detail?.seasons {
                self.setupSeasonsView(with: seasons, using: colors)
            }
            
            if let credits = self.detail?.credits {
                self.setupCastCollectionView(with: credits, using: colors)
            }
            
            if let safeCreatedBy = self.detail?.createdBy, safeCreatedBy.count > 0 {
                self.createdBy.configure(with: safeCreatedBy, colors: colors, and: "Created By")
            } else {
                self.createdBy.removeFromSuperview()
                self.overviewStack.topAnchor.constraint(equalTo: self.backdropDetail.bottomAnchor, constant: T.Spacing.Vertical(size: .large)).isActive = true
            }
            
            if let recommendations = self.detail?.recommendations?.results {
                self.setupRecommendationsView(with: recommendations, using: colors)
            }
            self.view.hideSkeleton()
        }
    }
}

// MARK: - CreatorsCollectionViewDelegate
extension ShowDetailViewController: CreatorsCollectionVIewDelegate {
    func select(crew: Crew) {
        guard let safeColors = colors else { return }
        let creditVC = CreditDetailViewController(with: crew, using: safeColors)
        creditVC.delegate = self
        let navController = UINavigationController(rootViewController: creditVC)
        present(navController, animated: true)
    }
}

// MARK: - CastCollectionViewDelegate
extension ShowDetailViewController: CastCollectionViewDelegate {
    func select(cast: Cast) {
        guard let safeColors = colors else { return }
        let creditVC = CreditDetailViewController(with: cast, using: safeColors)
        creditVC.delegate = self
        let navController = UINavigationController(rootViewController: creditVC)
        present(navController, animated: true)
    }
}

// MARK: - ShowDetailSeasonsDelegate
extension ShowDetailViewController: ShowDetailSeasonsDelegate {
    func select(season: Season) {
        guard let safeColors = colors else { return }
        let seasonModal = SeasonsView(tvId: show.id, season: season, colors: safeColors)
        seasonModal.creditVCDelegate = self
        let navController = UINavigationController(rootViewController: seasonModal)
        tabBarController?.present(navController, animated: true)
    }
}

// MARK: - ShowDetailRecommendationsDelegate
extension ShowDetailViewController: ShowDetailRecommendationsDelegate {
    func select(show: Show) {
        let detailVC = ShowDetailViewController(with: show)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CreditDetailDelegate
extension ShowDetailViewController: CreditDetailDelegate {
    func shouldPush(VC: UIViewController) {
        navigationController?.pushViewController(VC, animated: true)
    }
}
