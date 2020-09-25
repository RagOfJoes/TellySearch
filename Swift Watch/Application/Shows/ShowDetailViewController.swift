//
//  ShowDetailViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 9/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises

class ShowDetailViewController: UIViewController {
    // MARK: - Internal Properties
    let show: Show
    var colors: UIImageColors?
    
    var containerView: UIView
    var scrollView: UIScrollView
    
    private lazy var backdropDetail = BackdropDetail()
    private lazy var createdBy: CreatorsCollectionView = {
        let createdBy = CreatorsCollectionView()
        createdBy.delegate = self
        
        return createdBy
    }()
    
    private lazy var overviewStack: InfoStackView = {
        let overviewStack = InfoStackView(fontSize: (18, 14))
        return overviewStack
    }()
    
    private lazy var seasonsView: ShowDetailSeasons = {
        let seasonsView = ShowDetailSeasons(.Regular)
        
        return seasonsView
    }()
    
    private lazy var castCollectionView: CastCollectionView = {
        let castCollectionView = CastCollectionView(.RegularHasSecondary)
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
        
        stackView.setCustomSpacing(20, after: seasonsView)
        stackView.setCustomSpacing(20, after: castCollectionView)
        stackView.setCustomSpacing(20, after: recommendationsView)
        
        return stackView
    }()
    
    // MARK: - Lifecycle
    init(with show: Show) {
        self.show = show
        
        let (sV, cV) = UIView.createScrollView()
        self.scrollView = sV
        self.containerView = cV
        
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
        setupDetailUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav(by: true)
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // When User leaves View
        // retain colors and ensure that we're
        // resetting Nav color to appropriate Color
        if let safeColors = self.colors {
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.navigationController?.navigationBar.tintColor = safeColors.primary
                }
            }
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
    private func setupUIColors(with colors: UIImageColors) {
        view.backgroundColor = colors.background
        navigationController?.navigationBar.tintColor = colors.primary
    }
    
    func setupNav(by disappearing: Bool) {
        if disappearing {
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            
            guard let tbc = self.tabBarController as? TabBarController else { return }
            tbc.hideTabBar(hide: true)
        } else {
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            
            UIView.animate(withDuration: 0.25) {
                self.navigationController?.navigationBar.prefersLargeTitles = true
            }
            
            guard let tbc = self.tabBarController as? TabBarController else { return }
            tbc.hideTabBar(hide: false)
        }
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
            createdBy.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            createdBy.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            createdBy.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: 20),
        ]
        NSLayoutConstraint.activate(createdByConstraints)
        
        let overviewStackConstraints: [NSLayoutConstraint] = [
            overviewStack.topAnchor.constraint(equalTo: createdBy.bottomAnchor, constant: 20),
            overviewStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            overviewStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
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
            stackView.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
    private func updateContentSize() {
        let offsetHeight:CGFloat = K.ScrollOffsetHeight
        let screen = UIScreen.main.bounds
        
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
        self.show.fetchDetail().then({ data -> Promise<ShowDetail> in
            return ShowDetail.decodeShowData(data: data)
        }).then({ detail -> Promise<Void> in
            let (genres, runtime) = self.setupBackdropText(with: detail)
            
            let title = self.show.name
            let releaseDate = self.show.firstAirDate
            let posterURL = self.show.posterPath != nil ? K.Poster.URL + (self.show.posterPath!) : nil
            let backdropURL = self.show.backdropPath != nil ? K.Backdrop.URL + (self.show.backdropPath!) : nil
            
            // Return Void Promise to allow Recommendations to setup UI
            return Promise<Void>(on: .promises) { (fulfill, reject) in
                self.backdropDetail.configure(backdropURL: backdropURL, posterURL: posterURL, title: title, genres: genres, runtime: runtime, releaseDate: releaseDate) { colors in
                    self.setupSeasonsView(with: detail.seasons, using: colors)
                    
                    if let credits = detail.credits {
                        self.setupCastCollectionView(with: credits, using: colors)
                    }
                    
                    if let safeCreatedBy = detail.createdBy, safeCreatedBy.count > 0 {
                        self.createdBy.configure(with: safeCreatedBy, colors: colors, and: "Created By")
                    } else {
                        self.createdBy.removeFromSuperview()
                        self.overviewStack.topAnchor.constraint(equalTo: self.backdropDetail.bottomAnchor, constant: 20).isActive = true
                    }
                    
                    if let recommendations = detail.recommendations?.results {
                        self.setupRecommendationsView(with: recommendations, using: colors)
                    }
                    
                    fulfill(Void())
                }
            }
        }).then {
            DispatchQueue.main.async {
                self.updateContentSize()
            }
        }
    }
    
    private func setupCastCollectionView(with credits: Credits, using colors: UIImageColors) {
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
    
    private func setupSeasonsView(with seasons: [Season], using colors: UIImageColors) {
        if seasons.count <= 0 {
            stackView.removeArrangedSubview(seasonsView)
            seasonsView.removeFromSuperview()
            return
        }
        seasonsView.configure(with: seasons.reversed(), colors: colors)
    }
    
    private func setupRecommendationsView(with shows: [Show], using colors: UIImageColors) {
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

// MARK: - CreatorsCollectionViewDelegate
extension ShowDetailViewController: CreatorsCollectionVIewDelegate {
    func select(crew: Crew) {
        guard let safeColors = self.colors else { return }
        let creditModal = CreditDetailModal(with: crew, using: safeColors)
        creditModal.delegate = self
        let navController = UINavigationController(rootViewController: creditModal)
        self.present(navController, animated: true)
    }
}

// MARK: - CastCollectionViewDelegate
extension ShowDetailViewController: CastCollectionViewDelegate {
    func select(cast: Cast) {
        guard let safeColors = self.colors else { return }
        let creditModal = CreditDetailModal(with: cast, using: safeColors)
        creditModal.delegate = self
        let navController = UINavigationController(rootViewController: creditModal)
        self.present(navController, animated: true)
    }
}

// MARK: - MovieDetailRecommendationsDelegate
extension ShowDetailViewController: ShowDetailRecommendationsDelegate {
    func select(show: Show) {
        let detailVC = ShowDetailViewController(with: show)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ShowDetailViewController: CreditDetailModalDelegate {
    func shouldPush(VC: UIViewController) {
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
