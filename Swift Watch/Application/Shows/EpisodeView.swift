//
//  EpisodeView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 10/2/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher
import SkeletonView

class EpisodeView: UIViewController {
    // MARK: - Internal Properties
    private let episode: Episode
    private let colors: UIImageColors
    
    private var scrollView = UIScrollView()
    private var containerView = UIView()
    
    private lazy var backdrop: UIImageView = {
        let backdrop = UIImageView()
        backdrop.clipsToBounds = true
        backdrop.contentMode = .scaleAspectFill
        backdrop.roundCorners(.allCorners, radius: 5)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        backdrop.isSkeletonable = true
        backdrop.skeletonCornerRadius = 5
        return backdrop
    }()
    
    private lazy var airDate: InfoStackView = {
        let airDate = InfoStackView(using: colors)
        return airDate
    }()
    
    private lazy var overview: InfoStackView = {
        let overview = InfoStackView(using: colors)
        return overview
    }()
    
    private lazy var guestStars: CastCollectionView = {
        let guestStars = CastCollectionView(.RegularSecondary)
        return guestStars
    }()
    
    // MARK: - Life Cycle
    init(episode: Episode, colors: UIImageColors) {
        self.colors = colors
        self.episode = episode
        
        let (sV, cV) = UIView.createScrollView()
        scrollView = sV
        containerView = cV
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        view.backgroundColor = colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(backdrop)
        containerView.addSubview(airDate)
        containerView.addSubview(overview)
        containerView.addSubview(guestStars)
        
        setupAnchor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.configureSubviews()
            self.updateContentSize()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views Setup
extension EpisodeView {
    @objc func onBackButton() {
        dismiss(animated: true)
    }
    
    private func setupNav() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: colors.background), for: .default)
        
        navigationController?.navigationBar.tintColor = colors.primary
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colors.primary!]

        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.title = episode.name
        navigationItem.rightBarButtonItem = backBarButton
    }
    
    private func setupAnchor() {
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
        
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: containerView.topAnchor),
            backdrop.heightAnchor.constraint(equalToConstant: SeasonsViewCell.backdropHeight),
            backdrop.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal()),
            backdrop.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let airDateConstraints: [NSLayoutConstraint] = [
            airDate.topAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            airDate.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal()),
            airDate.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(airDateConstraints)
        
        let overviewConstraints: [NSLayoutConstraint] = [
            overview.topAnchor.constraint(equalTo: airDate.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            overview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal()),
            overview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(overviewConstraints)
        
        let guestStarsConstraints: [NSLayoutConstraint] = [
            guestStars.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            guestStars.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            guestStars.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: T.Spacing.Vertical(size: .large))
        ]
        NSLayoutConstraint.activate(guestStarsConstraints)
    }
}

// MARK: - Subviews Setup
extension EpisodeView {
    func setCastViewDelegate(_ delegate: CastCollectionViewDelegate) {
        guestStars.delegate = delegate
    }
    
    private func updateContentSize() {
        let viewFrame = view.frame
        let offsetHeight: CGFloat = K.ScrollOffsetHeight
        
        var contentHeight: CGFloat = viewFrame.height
        if guestStars.isDescendant(of: view) {
            let guestStarsY = guestStars.frame.maxY
            if guestStarsY > viewFrame.height {
                contentHeight = guestStarsY + offsetHeight
            }
        } else {
            let overviewY = overview.frame.maxY
            
            if overviewY > viewFrame.height {
                contentHeight = overviewY + offsetHeight
            }
        }
        
        scrollView.contentSize = CGSize(width: viewFrame.width, height: contentHeight)
    }
    
    private func configureSubviews() {
        let placeholder = UIImage(named: "placeholderBackdrop")
        if let urlString = episode.backdrop {
            let validURL = URL(string: K.URL.Backdrop + urlString)
            let options: KingfisherOptionsInfo = [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
            ]
            backdrop.kfSetImage(with: validURL, using: placeholder, options: options)
        } else {
            backdrop.image = placeholder
        }
        
        let airDateString = episode.airDate?.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
            return "\(month) \(day), \(year)"
        }) ?? "-"
        airDate.setup(title: "Air Date", value: airDateString)
        
        if let safeOverview = episode.overview, safeOverview.count > 0 {
            overview.setup(title: "Overview", value: safeOverview)
        } else {
            overview.setup(title: "Overview", value: "-")
        }
        
        if let cast = episode.credits.cast, cast.count > 0 {
            guestStars.configure(with: episode.credits, title: "Guest Stars", colors: colors)
        } else {
            guestStars.removeFromSuperview()
        }
    }
}
