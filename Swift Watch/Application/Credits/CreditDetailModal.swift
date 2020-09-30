//
//  CreditDetailModal.swift
//  Swift Watch
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

protocol CreditDetailModalDelegate: class {
    func shouldPush(VC: UIViewController)
}

class CreditDetailModal: UIViewController {
    // MARK: - Internal Properties
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let cast: Cast?
    private let crew: Crew?
    private let type: CreditDetailType
    
    private let colors: UIImageColors
    private var personDetail: PersonDetail?
    weak var delegate: CreditDetailModalDelegate?
    
    private var scrollView: UIScrollView
    private var containerView: UIView
    private lazy var poster: PosterImageView = {
        if self.type == .Cast {
            return PosterImageView(with: self.cast?.profilePath)
        } else {
            return PosterImageView(with: self.crew?.profilePath)
        }
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.colors.primary
        label.setupFont(size: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        if self.type == .Cast {
            label.text = self.cast?.name
        } else {
            label.text = self.crew?.name
        }
        return label
    }()
    
    private lazy var genderLabels: InfoStackView = {
        return InfoStackView(using: self.colors, fontSize: (14, 14))
    }()
    private lazy var bornLabels: InfoStackView = {
        return InfoStackView(using: self.colors, fontSize: (14, 14))
    }()
    private lazy var diedLabels: InfoStackView = {
        return InfoStackView(using: self.colors, fontSize: (14, 14))
    }()
    private lazy var birthplaceStack: InfoStackView = {
        return InfoStackView(using: self.colors, fontSize: (14, 14))
    }()
    
    private lazy var personalStackViews: UIStackView = {
        let personalStackViews = UIStackView(arrangedSubviews: [nameLabel, genderLabels, bornLabels, diedLabels])
        personalStackViews.axis = .vertical
        return personalStackViews
    }()
    
    private lazy var personStackView: UIStackView = {
        let personStackView = UIStackView(arrangedSubviews: [poster, personalStackViews])
        personStackView.alignment = .bottom
        personStackView.setCustomSpacing(5, after: poster)
        personStackView.translatesAutoresizingMaskIntoConstraints = false
        return personStackView
    }()
    
    private lazy var knownForStack: InfoStackView = {
        return InfoStackView(using: self.colors, fontSize: (14, 14))
    }()
    private lazy var biographyStack: InfoStackView = {
        let biographyStack = InfoStackView(using: self.colors, hasReadMore: true, fontSize: (14, 14))
        biographyStack.delegate = self
        return biographyStack
    }()
    
    private lazy var bodyStackView: UIStackView = {
        let bodyStackView = UIStackView(arrangedSubviews: [knownForStack, biographyStack])
        bodyStackView.axis = .vertical
        bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        return bodyStackView
    }()
    
    private lazy var notableWorks: CreditDetailNotableWorks = {
        let notableWorks = CreditDetailNotableWorks(.RegularHasSecondary, colors: self.colors)
        notableWorks.delegate = self
        return notableWorks
    }()
    
    // MARK: - Life Cycle
    init(with cast: Cast, using colors: UIImageColors) {
        self.crew = nil
        self.cast = cast
        self.type = .Cast
        self.colors = colors
        
        let (sV, cV) = UIView.createScrollView()
        self.scrollView = sV
        self.containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(with crew: Crew, using colors: UIImageColors) {
        self.cast = nil
        self.crew = crew
        self.type = .Crew
        self.colors = colors
        
        let (sV, cV) = UIView.createScrollView()
        self.scrollView = sV
        self.containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        view.backgroundColor = self.colors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(personStackView)
        containerView.addSubview(bodyStackView)
        containerView.addSubview(notableWorks)
        
        setupAnchors()
        fetchDetails()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Setup
extension CreditDetailModal {
    @objc func onBackButton() {
        self.dismiss(animated: true)
    }
    
    private func setupNav() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        self.navigationController?.navigationBar.tintColor = colors.primary
        let backBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        navigationItem.rightBarButtonItem = backBarButton
    }
    
    private func setupAnchors() {
        let scrollViewConstraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)
        
        var containerViewTopConstant: CGFloat
        
        if let navBar = self.navigationController?.navigationBar {
            containerViewTopConstant = navBar.frame.height
        } else {
            containerViewTopConstant = 0
        }
        let containerViewConstraints: [NSLayoutConstraint] = [
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: containerViewTopConstant),
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        
        let hStackConstraints: [NSLayoutConstraint] = [
            personStackView.heightAnchor.constraint(equalToConstant: K.Poster.height),
            personStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 30),
            personStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            personStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
        ]
        NSLayoutConstraint.activate(hStackConstraints)
        
        let bodyStackConstraints: [NSLayoutConstraint] = [
            bodyStackView.topAnchor.constraint(equalTo: self.personStackView.bottomAnchor, constant: 20),
            bodyStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            bodyStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
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
            notableWorks.topAnchor.constraint(equalTo: bodyStackView.bottomAnchor, constant: 20),
        ]
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
    
    private func updateContentSize() {
        let viewFrame = self.view.frame
        let offsetHeight:CGFloat = K.ScrollOffsetHeight * 2
        
        if notableWorks.isDescendant(of: self.view) {
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
extension CreditDetailModal {
    private func setupPersonalLabels(title: String, value: String?, parentView: UIStackView?, view: InfoStackView?, previousView: UIView?) {
        guard let safeParent = parentView else { return }
        guard let safeView = view else { return }
        guard let safeValue = value else {
            safeParent.removeArrangedSubview(safeView)
            safeView.removeFromSuperview()
            return
        }
        
        DispatchQueue.main.async {
            safeView.setup(title: title, value: safeValue, colors: self.colors)
        }
        
        guard let safePreviousView = previousView else { return }
        safeParent.setCustomSpacing(20, after: safePreviousView)
    }
}

// MARK: - Data Fetchers
extension CreditDetailModal {
    private func fetchDetails() {
        var personDetailData: Promise<PersonDetail>
        if self.cast != nil && self.type == .Cast {
            personDetailData = self.cast!.fetchDetail().then({ data -> Promise<PersonDetail> in
                return PersonDetail.decodePersonDetail(data: data)
            })
        } else if self.crew != nil && self.type == .Crew {
            personDetailData = self.crew!.fetchDetail().then({ data -> Promise<PersonDetail> in
                return PersonDetail.decodePersonDetail(data: data)
            })
        } else {
            self.setupPersonalLabels(title: "Gender", value: "-", parentView: self.personalStackViews, view: self.genderLabels, previousView: self.nameLabel)
            self.setupPersonalLabels(title: "Born", value: "-", parentView: self.personalStackViews, view: self.bornLabels, previousView: self.genderLabels)
            self.setupPersonalLabels(title: "Died", value: "-", parentView: self.personalStackViews, view: self.diedLabels, previousView: self.bornLabels)
            self.setupPersonalLabels(title: "Place Of Birth", value: "-", parentView: self.personalStackViews, view: self.birthplaceStack, previousView: (self.diedLabels.isDescendant(of: self.personalStackViews)) ? self.diedLabels : self.bornLabels)
            self.setupPersonalLabels(title: "Known For", value: "-", parentView: self.bodyStackView, view: self.knownForStack, previousView: self.birthplaceStack)
            self.setupPersonalLabels(title: "About", value: "-", parentView: self.bodyStackView, view: self.biographyStack, previousView: self.knownForStack)
            
            self.notableWorks.removeFromSuperview()
            return
        }
        
        personDetailData.then { [weak self] (data) in
            self?.personDetail = data
            
            self?.setupPersonalLabels(title: "Gender", value: data.genderStr, parentView: self?.personalStackViews, view: self?.genderLabels, previousView: self?.nameLabel)
            self?.setupPersonalLabels(title: "Born", value: data.born, parentView: self?.personalStackViews, view: self?.bornLabels, previousView: self?.genderLabels)
            self?.setupPersonalLabels(title: "Died", value: data.died, parentView: self?.personalStackViews, view: self?.diedLabels, previousView: self?.bornLabels)
            self?.setupPersonalLabels(title: "Place Of Birth", value: data.birthPlace, parentView: self?.personalStackViews, view: self?.birthplaceStack, previousView: (self?.diedLabels.isDescendant(of: self!.personalStackViews))! ? self?.diedLabels : self?.bornLabels)
            self?.setupPersonalLabels(title: "Known For", value: data.knownFor, parentView: self?.bodyStackView, view: self?.knownForStack, previousView: self?.birthplaceStack)
            self?.setupPersonalLabels(title: "About", value: data.biography.count <= 0 ? "-" : data.biography, parentView: self?.bodyStackView, view: self?.biographyStack, previousView: self?.knownForStack)
            
            if let notableWorks = data.notableWorks, notableWorks.count > 0 {
                DispatchQueue.main.async {
                    self?.notableWorks.configure(with: notableWorks)
                }
            } else {
                self?.notableWorks.removeFromSuperview()
            }
        }.always { [weak self] in
            DispatchQueue.main.async {
                self?.updateContentSize()
            }
        }
    }
}

// MARK: - InfoStackViewDelegate
extension CreditDetailModal: InfoStackViewDelegate {
    func didReadMore() {
        DispatchQueue.main.async {
            self.scrollView.layoutIfNeeded()
            self.updateContentSize()
        }
    }
}

// MARK: - CreditDetailNotableWorksDelegate
extension CreditDetailModal: CreditDetailNotableWorksDelegate {
    func select(media: Media) {
        guard let type = media.mediaType else { return }
        
        if type == .tv {
            let show = Show(id: media.id, name: media.name!, overview: media.overview, posterPath: media.posterPath, firstAirDate: media.firstAirDate!, backdropPath: media.backdropPath)
            let detailVC = ShowDetailViewController(with: show)
            self.navigationController?.dismiss(animated: true, completion: {
                self.delegate?.shouldPush(VC: detailVC)
            })
        } else {
            let movie = Movie(id: media.id, title: media.title!, overview: media.overview, releaseDate: media.releaseDate ?? "", posterPath: media.posterPath, backdropPath: media.backdropPath)
            let detailVC = MovieDetailViewController(with: movie)
            self.navigationController?.dismiss(animated: true, completion: {
                self.delegate?.shouldPush(VC: detailVC)
            })
        }
    }
}
