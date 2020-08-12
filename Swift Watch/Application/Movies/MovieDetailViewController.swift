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
import SkeletonView

class MovieDetailViewController: UIViewController {
    
    var movie: Movie?
    // MARK: - Views Declaration
    private lazy var backdropDetail: BackdropDetail = {
        let backdropDetail = BackdropDetail()
        backdropDetail.delegate = self
        backdropDetail.translatesAutoresizingMaskIntoConstraints = false
        
        return backdropDetail
    }()
    
    private lazy var overviewTitle: UILabel = {
        let overviewTitle = UILabel()
        overviewTitle.alpha = 0.4
        overviewTitle.numberOfLines = 1
        overviewTitle.translatesAutoresizingMaskIntoConstraints = false
        overviewTitle.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .bold))
        
        overviewTitle.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        return overviewTitle
    }()
    
    private lazy var overview: UILabel = {
        let overview = UILabel()
        let font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        overview.font = font
        overview.numberOfLines = 0
        overview.translatesAutoresizingMaskIntoConstraints = false
        
        var height: CGFloat
        if  let overview = movie?.overview {
            height = overview.height(font: font)
        } else {
            height = 0
        }
        
        overview.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        return overview
    }()
    
    private lazy var overviewStack: UIStackView = {
        let overviewStack = UIStackView(arrangedSubviews: [overviewTitle, overview])
        overviewStack.axis = .vertical
        overviewStack.setCustomSpacing(5, after: overviewTitle)
        overviewStack.translatesAutoresizingMaskIntoConstraints = false
        
        overviewStack.isSkeletonable = true
        overviewStack.skeletonCornerRadius = 5
        overviewStack.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))
        
        return overviewStack
    }()
    
    private lazy var creditsCollectionView: CastCollectionView = {
        let creditsCollectionView = CastCollectionView()
        creditsCollectionView.backgroundColor = .clear
        creditsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return creditsCollectionView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
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
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(backdropDetail)
        containerView.addSubview(overviewStack)
        containerView.addSubview(creditsCollectionView)
        
        setupAnchors()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNav(by: true)
        
        setupDetailUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.25) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNav(by: false)
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
        
        let backdropDetailConstraints: [NSLayoutConstraint] = [
            backdropDetail.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdropDetail.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backdropDetail.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropDetailConstraints)
        
        let overviewConstraints: [NSLayoutConstraint] = [
            overviewStack.topAnchor.constraint(equalTo: backdropDetail.bottomAnchor, constant: 20),
            overviewStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            overviewStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ]
        NSLayoutConstraint.activate(overviewConstraints)
        
        let creditCollectionViewHeight: CGFloat = CastCollectionView.collectionViewHeight + 35
        let creditsContraints: [NSLayoutConstraint] = [
            creditsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            creditsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            creditsCollectionView.heightAnchor.constraint(equalToConstant: creditCollectionViewHeight),
            creditsCollectionView.topAnchor.constraint(equalTo: overviewStack.bottomAnchor, constant: 25),
        ]
        NSLayoutConstraint.activate(creditsContraints)
    }
    
    // MARK: - Colors UI
    private func setupUIColors(with colors: UIImageColors) {
        
        view.backgroundColor = colors.background
        
        overview.textColor = colors.primary
        overviewTitle.textColor = colors.primary
        navigationController?.navigationBar.tintColor = colors.primary
    }
    
    // MARK: - Detail UI
    private func setupDetailUI() {
        // Fetch Movie Details
        // then set Backdrop
        movie?.fetchDetail().then({ (detail) in
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
                    
                    if hours <= 0 {
                        runtimeStr = "\(minutes) mins"
                    } else if hours == 1 {
                        runtimeStr = "\(hours) hr \(minutes) mins"
                    } else {
                        runtimeStr = "\(hours) hrs \(minutes) mins"
                    }
                }
            }
            
            if let safeUrl = self.movie?.backdropPath {
                self.backdropDetail.configure(url: MovieSection.backdropURL + safeUrl, title: self.movie?.title, genres: genresStr, runtime: runtimeStr, releaseDate: self.movie?.releaseDate)
            } else {
                self.backdropDetail.configure(url: nil, title: self.movie?.title, genres: genresStr, runtime: runtimeStr, releaseDate: self.movie?.releaseDate)
            }
        })
    }
}

// MARK: - Section Header
extension MovieDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

// MARK: - BackdropDetailDelegate
extension MovieDetailViewController: BackdropDetailDelegate {
    func didSetupUI(colors: UIImageColors) {
        self.movie?.fetchCredits().then({ (credits) in
            self.creditsCollectionView.configure(with: credits, _colors: colors)
            
            DispatchQueue.main.async {
                self.overviewStack.hideSkeleton(transition: .crossDissolve(0.25))
                UIView.animate(withDuration: 0.27) {
                    self.setupUIColors(with: colors)
                    
                    self.overviewTitle.text = "Overview"
                    self.overview.text = self.movie?.overview
                }
            }
            
            let screen = UIScreen.main.bounds
            let creditsY = self.creditsCollectionView.frame.maxY
            
            if creditsY > screen.height {
                self.scrollView.contentSize = CGSize(width: screen.width, height: creditsY + 25)
            } else {
                self.scrollView.contentSize = CGSize(width: screen.width, height: screen.height)
            }
        })
    }
}
