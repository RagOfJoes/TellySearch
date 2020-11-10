//
//  CreditDetailViewController.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/12/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher

enum CreditDetailType {
    case Cast
    case Crew
}

protocol CreditDetailDelegate: class {
    func shouldPush(VC: UIViewController)
}

class CreditDetailViewController: UIViewController {
    // MARK: - Internal Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let cast: Cast?
    private let crew: Crew?
    private let type: CreditDetailType
    private var personStackHeightConstraint: NSLayoutConstraint!
    
    private let colors: UIImageColors
    private var personDetail: PersonDetail?
    weak var delegate: CreditDetailDelegate?
    
    private var scrollView: UIScrollView
    private var containerView: UIView
    private lazy var poster: Poster = {
        let poster: Poster
        if type == .Cast {
            poster = Poster(with: cast?.profilePath)
        } else {
            poster = Poster(with: crew?.profilePath)
        }
        return poster
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = colors.primary
        label.font = T.Typography(variant: .HeadingOne).font
        label.translatesAutoresizingMaskIntoConstraints = false
        
        if type == .Cast {
            label.text = cast?.name
        } else {
            label.text = crew?.name
        }
        
        label.isSkeletonable = true
        return label
    }()
    private lazy var genderLabels: InfoStackView = {
        return InfoStackView(using: colors)
    }()
    private lazy var lifetimeLabel: InfoStackView = {
        return InfoStackView(using: colors)
    }()
    private lazy var personalStackViews: UIStackView = {
        let personalStackViews = UIStackView(arrangedSubviews: [nameLabel, genderLabels, lifetimeLabel])
        personalStackViews.axis = .vertical
        personalStackViews.translatesAutoresizingMaskIntoConstraints = false
        personalStackViews.isSkeletonable = true
        return personalStackViews
    }()
    
    private lazy var knownForStack: InfoStackView = {
        return InfoStackView(using: colors)
    }()
    private lazy var biographyStack: InfoStackView = {
        let biographyStack = InfoStackView(using: colors, hasReadMore: true)
        biographyStack.delegate = self
        return biographyStack
    }()
    
    private lazy var bodyStackView: UIStackView = {
        let bodyStackView = UIStackView(arrangedSubviews: [knownForStack, biographyStack])
        bodyStackView.axis = .vertical
        bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bodyStackView.isSkeletonable = true
        return bodyStackView
    }()
    
    private lazy var notableWorks: CreditDetailNotableWorks = {
        let notableWorks = CreditDetailNotableWorks(colors: colors)
        notableWorks.delegate = self
        return notableWorks
    }()
    
    // MARK: - Life Cycle
    init(with cast: Cast, using colors: UIImageColors) {
        crew = nil
        type = .Cast
        self.cast = cast
        self.colors = colors
        
        let (sV, cV) = UIView.createScrollView()
        scrollView = sV
        containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(with crew: Crew, using colors: UIImageColors) {
        cast = nil
        type = .Crew
        self.crew = crew
        self.colors = colors
        
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
        containerView.addSubview(poster)
        containerView.addSubview(personalStackViews)
        containerView.addSubview(bodyStackView)
        containerView.addSubview(notableWorks)
        
        view.isSkeletonable = true
        scrollView.isSkeletonable = true
        containerView.isSkeletonable = true
        containerView.showAnimatedSkeleton()
        
        setupAnchors()
        fetchDetails()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup
extension CreditDetailViewController {
    @objc func onBackButton() {
        dismiss(animated: true)
    }
    
    private func setupNav() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: colors.background), for: .default)
        
        navigationController?.navigationBar.tintColor = colors.primary
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.rightBarButtonItem = backBarButton
    }
    
    private func setupAnchors() {
        let scrollViewConstraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        let containerViewConstraints: [NSLayoutConstraint] = [
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        
        let posterConstraints: [NSLayoutConstraint] = [
            poster.topAnchor.constraint(equalTo: containerView.topAnchor),
            poster.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(posterConstraints)
        
        let personalConstraints: [NSLayoutConstraint] = [
            personalStackViews.bottomAnchor.constraint(equalTo: poster.bottomAnchor),
            personalStackViews.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal()),
            personalStackViews.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: T.Spacing.Horizontal(size: .small)),
        ]
        NSLayoutConstraint.activate(personalConstraints)
        
        let bodyStackConstraints: [NSLayoutConstraint] = [
            bodyStackView.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            bodyStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: T.Spacing.Horizontal()),
            bodyStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(bodyStackConstraints)
        
        var notableWorksLeading: NSLayoutConstraint!
        var notableWorksTrailing: NSLayoutConstraint!
        
        if #available(iOS 11, *) {
            notableWorksLeading = notableWorks.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor)
            notableWorksTrailing = notableWorks.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
        } else {
            notableWorksLeading = notableWorks.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
            notableWorksTrailing = notableWorks.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        }
        
        let collectionViewConstraints: [NSLayoutConstraint] = [
            notableWorksLeading,
            notableWorksTrailing,
            notableWorks.topAnchor.constraint(equalTo: bodyStackView.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
    
    private func updateContentSize() {
        let viewFrame = view.frame
        let offsetHeight: CGFloat = K.ScrollOffsetHeight
        
        if notableWorks.isDescendant(of: view) {
            let notableWorksY = notableWorks.frame.maxY + offsetHeight
            if notableWorksY > viewFrame.height {
                scrollView.contentSize = CGSize(width: viewFrame.width, height: notableWorksY)
            } else {
                scrollView.contentSize = CGSize(width: viewFrame.width, height: viewFrame.height)
            }
        } else {
            let stackViewY = bodyStackView.frame.maxY + offsetHeight
            
            if stackViewY > viewFrame.height {
                scrollView.contentSize = CGSize(width: viewFrame.width, height: stackViewY)
            } else {
                scrollView.contentSize = CGSize(width: viewFrame.width, height: viewFrame.height)
            }
        }
    }
}

// MARK: - SubViews Setup
extension CreditDetailViewController {
    private func setupPersonalLabels(title: String, value: String, customSpacing: CGFloat = T.Spacing.Vertical(), parentView: UIStackView?, view: InfoStackView?, previousView: UIView?) {
        guard let safeParent = parentView else { return }
        guard let safeView = view else { return }
        
        DispatchQueue.main.async {
            safeView.setup(title: title, value: value, colors: self.colors)
        }
        
        guard let safePreviousView = previousView else { return }
        safeParent.setCustomSpacing(customSpacing, after: safePreviousView)
    }
}

// MARK: - Data Fetchers
extension CreditDetailViewController {
    private func fetchDetails() {
        let personDetailData: Promise<PersonDetail>
        if cast != nil && type == .Cast {
            personDetailData = NetworkManager.request(endpoint: PersonEndpoint.getPersonDetail(id: cast!.id), cache: C.Person, cacheKey: cast!.cacheKey)
        } else if crew != nil && type == .Crew {
            personDetailData = NetworkManager.request(endpoint: PersonEndpoint.getPersonDetail(id: crew!.id), cache: C.Person, cacheKey: crew!.cacheKey)
        } else {
            setupPersonalLabels(title: "Gender", value: "-", parentView: personalStackViews, view: genderLabels, previousView: nameLabel)
            setupPersonalLabels(title: "Born", value: "-", parentView: personalStackViews, view: lifetimeLabel, previousView: genderLabels)
            setupPersonalLabels(title: "Known For", value: "-", parentView: bodyStackView, view: knownForStack, previousView: lifetimeLabel)
            setupPersonalLabels(title: "About", value: "-", parentView: bodyStackView, view: biographyStack, previousView: knownForStack)
            
            notableWorks.removeFromSuperview()
            return
        }
        
        personDetailData.then { [weak self] (data) in
            self?.personDetail = data
            
            let lifetimeTitle = data.died == nil ? "Born" : "Born - Died"
            let lifetimeValue = data.died == nil ? data.born ?? "-" : "\(data.born ?? "-") - \(data.died ?? "-")"
            self?.setupPersonalLabels(title: "Gender", value: data.genderStr, parentView: self?.personalStackViews, view: self?.genderLabels, previousView: self?.nameLabel)
            self?.setupPersonalLabels(title: lifetimeTitle, value: lifetimeValue, parentView: self?.personalStackViews, view: self?.lifetimeLabel, previousView: self?.genderLabels)
            self?.setupPersonalLabels(title: "Known For", value: data.knownFor, parentView: self?.bodyStackView, view: self?.knownForStack, previousView: self?.lifetimeLabel)
            self?.setupPersonalLabels(title: "About", value: data.biography.count <= 0 ? "-" : data.biography, customSpacing: T.Spacing.Vertical(size: .large), parentView: self?.bodyStackView, view: self?.biographyStack, previousView: self?.knownForStack)
            
            if let notableWorks = data.notableWorks, notableWorks.count > 0 {
                DispatchQueue.main.async {
                    self?.notableWorks.configure(with: notableWorks)
                }
            } else {
                self?.notableWorks.removeFromSuperview()
            }
            
            DispatchQueue.main.async {
                self?.view.hideSkeleton()
            }
        }.catch { (e) in
            print(e)
        }
    }
}

// MARK: - InfoStackViewDelegate
extension CreditDetailViewController: InfoStackViewDelegate {
    func didReadMore() {
        DispatchQueue.main.async {
            self.updateContentSize()
        }
    }
}

// MARK: - CreditDetailNotableWorksDelegate
extension CreditDetailViewController: CreditDetailNotableWorksDelegate {
    func select(media: Media) {
        guard let type = media.mediaType else { return }
        var detailVC: UIViewController
        if type == .tv {
            let show = Show(id: media.id, name: media.name!, overview: media.overview, posterPath: media.posterPath, firstAirDate: media.firstAirDate!, backdropPath: media.backdropPath)
            detailVC = ShowDetailViewController(with: show)
        } else {
            let movie = Movie(id: media.id, title: media.title!, overview: media.overview, posterPath: media.posterPath, releaseDate: media.releaseDate ?? "", backdropPath: media.backdropPath)
            detailVC = MovieDetailViewController(with: movie)
        }
        
        navigationController?.dismiss(animated: true, completion: {
            self.delegate?.shouldPush(VC: detailVC)
        })
    }
}
