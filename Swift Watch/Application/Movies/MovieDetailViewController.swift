//
//  MovieDetailViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/30/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import SkeletonView

class MovieDetailViewController: UIViewController {
    // MARK: - Internal Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let movie: Movie
    private var detail: MovieDetail?
    private var colors: UIImageColors?
    
    private var containerView: UIView
    private var scrollView: UIScrollView
    private lazy var backdropDetail: BackdropDetail = {
        let backdropDetail = BackdropDetail()
        backdropDetail.delegate = self
        return backdropDetail
    }()
    
    private lazy var directedBy: CreatorsCollectionView = {
        let directedBy = CreatorsCollectionView()
        directedBy.delegate = self
        
        return directedBy
    }()
    
    private lazy var overviewStack: InfoStackView = {
        let overviewStack = InfoStackView()
        return overviewStack
    }()
    
    private lazy var castCollectionView: CastCollectionView = {
        let castCollectionView = CastCollectionView(.RegularSecondary)
        castCollectionView.delegate = self
        return castCollectionView
    }()
    
    private lazy var recommendationsView: MovieDetailRecommendations = {
        let recommendationsView = MovieDetailRecommendations(.Regular)
        recommendationsView.delegate = self
        return recommendationsView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [castCollectionView, recommendationsView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.setCustomSpacing(T.Spacing.Vertical(size: .large), after: castCollectionView)
        stackView.setCustomSpacing(T.Spacing.Vertical(size: .large), after: recommendationsView)
        
        stackView.isSkeletonable = true
        return stackView
    }()
    
    // MARK: - LifeCycle
    init(with movie: Movie) {
        self.movie = movie
        
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
        containerView.addSubview(directedBy)
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
                    self?.navigationController?.navigationBar.tintColor = safeColors.primary
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
extension MovieDetailViewController {
    private func setupUIColors(with colors: UIImageColors) {
        view.backgroundColor = colors.background
        navigationController?.navigationBar.tintColor = colors.primary
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
        
        let directedByConstraints: [NSLayoutConstraint] = [
            directedBy.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            directedBy.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            directedBy.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
        ]
        NSLayoutConstraint.activate(directedByConstraints)
        
        let overviewStackConstraints: [NSLayoutConstraint] = [
            overviewStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal()),
            overviewStack.topAnchor.constraint(equalTo: directedBy.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            overviewStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal())
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
        let offsetHeight: CGFloat = K.ScrollOffsetHeight
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
extension MovieDetailViewController {
    private func setupDetailUI() {
        movie.fetchDetail().then({ data -> Promise<MovieDetail> in
            return MovieDetail.decodeMovieData(data: data)
        }).then ({ [weak self] detail in
            let backdropText = self?.setupBackdropText(with: detail)
            
            let (genres, runtime) = backdropText ?? ("-", "-")
            
            let title = self?.movie.title
            let releaseDate = self?.movie.releaseDate
            
            let posterURL = self?.movie.posterPath != nil ? K.URL.Poster + (self?.movie.posterPath!)! : nil
            let backdropURL = self?.movie.backdropPath != nil ? K.URL.Backdrop + (self?.movie.backdropPath!)! : nil
            
            // Return Void Promise to allow Recommendations to setup UI
            self?.backdropDetail.configure(backdropURL: backdropURL, posterURL: posterURL, title: title, genres: genres, runtime: runtime, releaseDate: releaseDate)
            self?.detail = detail
        })
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
        castCollectionView.configure(with: credits, title: "Top Billed Cast", colors: colors)
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
}

// MARK: - BackdropDetailDelegate
extension MovieDetailViewController: BackdropDetailDelegate {
    func didSetupUI(colors: UIImageColors) {
        DispatchQueue.main.async {
            if let safeDirectors = self.detail?.directors, safeDirectors.count > 0 {
                self.directedBy.configure(with: safeDirectors, colors: colors, and: "Directed By")
            } else {
                self.directedBy.removeFromSuperview()
                self.overviewStack.topAnchor.constraint(equalTo: self.backdropDetail.bottomAnchor, constant: T.Spacing.Vertical(size: .large)).isActive = true
            }
            
            // Setup CollectionViews
            if let safeCredits = self.detail?.credits {
                self.setupCastCollectionView(with: safeCredits, using: colors)
            }
            if let safeRecommendations = self.detail?.recommendations?.results {
                self.setupRecommendationsView(with: safeRecommendations, using: colors)
            }
            self.view.hideSkeleton()
        }
    }
}

// MARK: - CreatorsCollectionViewDelegate
extension MovieDetailViewController: CreatorsCollectionVIewDelegate {
    func select(crew: Crew) {
        guard let safeColors = colors else { return }
        let creditModal = CreditDetailModal(with: crew, using: safeColors)
        creditModal.delegate = self
        let navController = UINavigationController(rootViewController: creditModal)
        present(navController, animated: true)
    }
}

// MARK: - CastCollectionViewDelegate
extension MovieDetailViewController: CastCollectionViewDelegate {
    func select(cast: Cast) {
        guard let safeColors = colors else { return }
        let creditModal = CreditDetailModal(with: cast, using: safeColors)
        creditModal.delegate = self
        let navController = UINavigationController(rootViewController: creditModal)
        present(navController, animated: true)
    }
}

// MARK: - MovieDetailRecommendationsDelegate
extension MovieDetailViewController: MovieDetailRecommendationsDelegate {
    func select(movie: Movie) {
        let detailVC = MovieDetailViewController(with: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - CreditDetailModalDelegate
extension MovieDetailViewController: CreditDetailModalDelegate {
    func shouldPush(VC: UIViewController) {
        navigationController?.pushViewController(VC, animated: true)
    }
}
