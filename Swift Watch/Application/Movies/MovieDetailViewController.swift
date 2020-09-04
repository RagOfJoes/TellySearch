//
//  MovieDetailViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/30/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises

class MovieDetailViewController: UIViewController {
    let movie: Movie
    var colors: UIImageColors?
    // MARK: - View Declarations
    var containerView: UIView
    var scrollView: UIScrollView
    private lazy var backdropDetail = BackdropDetail()
    private lazy var overviewStack: InfoStackView = {
        let overviewStack = InfoStackView(fontSize: (18, 14))
        return overviewStack
    }()
    
    private lazy var castCollectionView: CastCollectionView = {
        let castCollectionView = CastCollectionView()
        castCollectionView.delegate = self
        return castCollectionView
    }()
    
    private lazy var recommendationsView: MovieDetailRecommendations = {
        let recommendationsView = MovieDetailRecommendations()
        recommendationsView.delegate = self
        return recommendationsView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [castCollectionView, recommendationsView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.setCustomSpacing(20, after: castCollectionView)
        stackView.setCustomSpacing(20, after: recommendationsView)
        
        return stackView
    }()
    
    // MARK: - Init
    init(with movie: Movie) {
        self.movie = movie
        
        let (sV, cV) = UIView.createScrollView()
        self.scrollView = sV
        self.containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
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
        containerView.addSubview(stackView)
        
        setupAnchors()
        setupDetailUI()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
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
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(isMovingFromParent) {
            setupNav(by: false)
            AppUtility.lockOrientation(.all)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setup
extension MovieDetailViewController {
    // MARK: - Nav
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
        
        let backdropDetailConstraints: [NSLayoutConstraint] = [
            backdropDetail.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropDetail.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropDetailConstraints)
        
        let overviewStackConstraints: [NSLayoutConstraint] = [
            overviewStack.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: 20),
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
    
    // MARK: - Colors UI
    private func setupUIColors(with colors: UIImageColors) {
        view.backgroundColor = colors.background
        navigationController?.navigationBar.tintColor = colors.primary
    }
    
    // MARK: - Detail UI
    private func setupDetailUI() {
        self.movie.fetchDetail().then({ detail -> Promise<Void> in
            let (genres, runtime) = self.setupBackdropText(with: detail)
            
            let title = self.movie.title
            let releaseDate = self.movie.releaseDate
            let posterURL = self.movie.posterPath != nil ? MovieSection.posterURL + (self.movie.posterPath!) : nil
            let backdropURL = self.movie.backdropPath != nil ? MovieSection.backdropURL + (self.movie.backdropPath!) : nil
            
            // Return Void Promise to allow Recommendations to setup UI
            return Promise { (fulfill, reject) -> Void in
                self.backdropDetail.configure(backdropURL: backdropURL, posterURL: posterURL, title: title, genres: genres, runtime: runtime, releaseDate: releaseDate) { colors in
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
            DispatchQueue.main.async {
                self.updateContentSize()                
            }
        }
    }
    
    private func setupRecommendationsView(with movies: [Movie], using colors: UIImageColors) {
        if movies.count <= 0 {
            stackView.removeArrangedSubview(recommendationsView)
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
            self.overviewStack.setup(title: "Overview", value: self.movie.overview ?? "-", colors: colors)
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
        let offsetHeight:CGFloat = 90
        let screen = UIScreen.main.bounds
        
        let stackViewY = stackView.frame.maxY + offsetHeight
        if stackViewY > screen.height {
            scrollView.contentSize = CGSize(width: screen.width, height: stackViewY)
        } else {
            scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
        }
    }
}

// MARK: - CastCollectionViewDelegate
extension MovieDetailViewController: CastCollectionViewDelegate {
    func select(cast: Cast) {
        guard let safeColors = self.colors else { return }
        let creditModal = CreditDetailModal(with: cast, using: safeColors)
        self.present(creditModal, animated: true)
    }
}

// MARK: - MovieDetailRecommendationsDelegate
extension MovieDetailViewController: MovieDetailRecommendationsDelegate {
    func select(movie: Movie) {
        let detailVC = MovieDetailViewController(with: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
