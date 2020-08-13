//
//  MovieDetailViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/30/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher

class MovieDetailViewController: UIViewController {
    
    var movie: Movie?
    var colors: UIImageColors?
    // MARK: - Views Declaration
    private lazy var backdropDetail: BackdropDetail = {
        let backdropDetail = BackdropDetail()
        backdropDetail.translatesAutoresizingMaskIntoConstraints = false
        
        return backdropDetail
    }()
    
    private lazy var overviewStack = MovieDetailOverviewStack()
    private lazy var castCollectionView = CastCollectionView()
    private lazy var recommendationsView: MovieDetailRecommendations = {
        let recommendationsView = MovieDetailRecommendations()
        recommendationsView.delegate = self
        
        return recommendationsView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.delaysContentTouches = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Style Props
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let screen = UIScreen.main.bounds
        
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
        
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButton = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(backdropDetail)
        containerView.addSubview(overviewStack)
        containerView.addSubview(castCollectionView)
        containerView.addSubview(recommendationsView)
        
        setupAnchors()
        setupDetailUI()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNav(by: true)
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
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNav(by: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateContentSize()
        }
    }
    
    // MARK: - Configure
    func configure(with data: Movie) {
        guard let safeMovie = movie else {
            movie = data
            return
        }
        
        if data.id != safeMovie.id {
            movie = data
        }
    }
}

// MARK: - UI Setup
extension MovieDetailViewController {
    // MARK: - Nav
    private func setupNav(by disappearing: Bool) {
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
    
    // MARK: - Anchors
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
        
        let containerViewLeadingAnchor = containerView.safeAreaLayoutGuide.leadingAnchor
        let containerViewTrailingAnchor = containerView.safeAreaLayoutGuide.trailingAnchor
        
        let backdropDetailConstraints: [NSLayoutConstraint] = [
            backdropDetail.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropDetail.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropDetailConstraints)
        
        let overviewConstraints: [NSLayoutConstraint] = [
            overviewStack.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: 20),
            overviewStack.leadingAnchor.constraint(equalTo: containerViewLeadingAnchor, constant: 20),
            overviewStack.trailingAnchor.constraint(equalTo: containerViewTrailingAnchor, constant: -20),
        ]
        NSLayoutConstraint.activate(overviewConstraints)
        
        let castCollectionViewHeight: CGFloat = K.Cast.topBilledCellHeight + 35
        let castCollectionViewConstraints: [NSLayoutConstraint] = [
            castCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            castCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            castCollectionView.heightAnchor.constraint(equalToConstant: castCollectionViewHeight),
            castCollectionView.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: 25),
        ]
        NSLayoutConstraint.activate(castCollectionViewConstraints)
        
        setupRecommendationsConstraints()
    }
    
    // MARK: - RecommendationsConstraints
    private func setupRecommendationsConstraints() {
        let isCastInView: Bool = castCollectionView.isDescendant(of: containerView)
        
        let recommendationsUnderCast: NSLayoutConstraint = recommendationsView.topAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 25)
        let recommendationsUnderOverview: NSLayoutConstraint = recommendationsView.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: 25)
        let recommendationsViewTopConstraint: NSLayoutConstraint = isCastInView ? recommendationsUnderCast : recommendationsUnderOverview
        
        let recommendationsViewHeight: CGFloat = K.Overview.heightConstant + 35
        let recommendationsConstraints: [NSLayoutConstraint] = [
            recommendationsViewTopConstraint,
            recommendationsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            recommendationsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            recommendationsView.heightAnchor.constraint(equalToConstant: recommendationsViewHeight)
        ]
        NSLayoutConstraint.activate(recommendationsConstraints)
    }
    
    // MARK: - Colors UI
    private func setupUIColors(with colors: UIImageColors) {
        view.backgroundColor = colors.background
        navigationController?.navigationBar.tintColor = colors.primary
    }
    
    // MARK: - Detail UI
    private func setupDetailUI() {
        movie?.fetchDetail().then({ detail -> Promise<Void> in
            let (genres, runtime) = self.setupBackdropText(with: detail)
            
            let title = self.movie?.title
            let releaseDate = self.movie?.releaseDate
            let backdropURL = self.movie?.backdropPath != nil ? MovieSection.backdropURL + (self.movie?.backdropPath!)! : nil
            
            // Return Void Promise to allow Recommendations to setup UI
            return Promise(on: .main) { (fulfill, reject) -> Void in
                self.backdropDetail.configure(url: backdropURL, title: title, genres: genres, runtime: runtime, releaseDate: releaseDate) { colors in
                    if let credits = detail.credits {
                        self.setupCastCollectionView(with: credits, using: colors)
                    }
                    
                    if let recommendations = detail.recommendations?.results {
                        self.setupRecommendationsView(with: recommendations, using: colors)
                    }
                    fulfill(Void())
                }
            }
        }).always {
            self.updateContentSize()
        }
    }
    
    private func setupRecommendationsView(with movies: [Movie], using colors: UIImageColors) {
        if movies.count <= 0 {
            recommendationsView.removeFromSuperview()
            return
        }
        recommendationsView.configure(with: movies, colors: colors)
    }
    
    private func setupCastCollectionView(with credits: Credits, using colors: UIImageColors) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.27) {
                self.colors = colors
                
                self.setupUIColors(with: colors)
            }
            self.overviewStack.configure(title: "Overview", text: self.movie?.overview, colors: colors)
        }
        
        if credits.cast == nil {
            castCollectionView.removeFromSuperview()
            recommendationsView.updateConstraints()
            return
        } else if let safeCast = credits.cast {
            if safeCast.count <= 0 {
                castCollectionView.removeFromSuperview()
                recommendationsView.updateConstraints()
                return
            }
        }
        
        castCollectionView.configure(with: credits, colors: colors)
    }
    
    private func setupBackdropText(with detail: MovieDetail) -> (String?, String?) {
        var genresStr: String?
        var runtimeStr: String?
        if let safeGenres = detail.genres {
            let genresArr = safeGenres.map { (genre) -> String in
                return genre.name
            }
            
            genresStr = genresArr.joined(separator: ", ")
        }
        
        if let safeRuntime = detail.runtime {
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
    
    // MARK: - Update ScrollVIewContentSize
    private func updateContentSize() {
        let offsetHeight:CGFloat = 25
        let screen = UIScreen.main.bounds
        
        let isRecommendationsInView: Bool = recommendationsView.isDescendant(of: containerView)
        if isRecommendationsInView {
            let recommendationsY = recommendationsView.frame.maxY + offsetHeight
            if recommendationsY > screen.height {
                scrollView.contentSize = CGSize(width: screen.width, height: recommendationsY)
            } else {
                scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
            }
            return
        }
        
        let isCastInView: Bool = castCollectionView.isDescendant(of: containerView)
        if isCastInView {
            let castY = castCollectionView.frame.maxY + offsetHeight
            if castY > screen.height {
                scrollView.contentSize = CGSize(width: screen.width, height: castY)
            } else {
                scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
            }
        } else {
            let overviewY = overviewStack.frame.maxY + offsetHeight
            if overviewY > screen.height {
                scrollView.contentSize = CGSize(width: screen.width, height: overviewY)
            } else {
                scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
            }
        }
    }
}

// MARK: - MovieDetailRecommendationsDelegate
extension MovieDetailViewController: MovieDetailRecommendationsDelegate {
    func select(movie: Movie) {
        let detailVC = MovieDetailViewController()
        
        detailVC.configure(with: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func didUpdateConstraints() {
        setupRecommendationsConstraints()
    }
}
