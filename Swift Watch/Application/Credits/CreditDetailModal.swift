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

protocol CreditDetailModalDelegate: class {
    func shouldPush(VC: UIViewController)
}

class CreditDetailModal: UIViewController {
    weak var delegate: CreditDetailModalDelegate?
    
    private let person: Cast
    private let colors: UIImageColors
    private var personDetail: PersonDetail?
    
    private var scrollView: UIScrollView
    private var containerView: UIView
    private lazy var poster: PosterImageView = {
        let poster = PosterImageView(with: self.person.profilePath)
        return poster
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = self.person.name
        label.textColor = self.colors.primary
        label.setupFont(size: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    lazy var bodyStackView: UIStackView = {
        let bodyStackView = UIStackView(arrangedSubviews: [knownForStack, biographyStack])
        bodyStackView.axis = .vertical
        bodyStackView.translatesAutoresizingMaskIntoConstraints = false
        return bodyStackView
    }()
    
    lazy var notableWorks: CreditDetailNotableWorks = {
        let notableWorks = CreditDetailNotableWorks(colors: self.colors)
        notableWorks.delegate = self
        return notableWorks
    }()
    
    init(with person: Cast, using colors: UIImageColors) {
        self.person = person
        self.colors = colors
        
        let (sV, cV) = UIView.createScrollView()
        self.scrollView = sV
        self.containerView = cV
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
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

// MARK: - View Functions
extension CreditDetailModal {
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
        let offsetHeight:CGFloat = 45
        let view = self.view.frame
        
        if !notableWorks.isDescendant(of: self.view) {
            let stackViewY = bodyStackView.frame.maxY
            
            if stackViewY > view.height {
                scrollView.contentSize = CGSize(width: view.width, height: stackViewY)
            } else {
                scrollView.contentSize = CGSize(width: view.width, height: view.height)
            }
        }
        
        let notableWorksY = notableWorks.frame.maxY + offsetHeight
        if notableWorksY > view.height {
            scrollView.contentSize = CGSize(width: view.width, height: notableWorksY)
        } else {
            scrollView.contentSize = CGSize(width: view.width, height: view.height)
        }
    }
}

// MARK: - Helper Functions
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
    
    private func fetchDetails() {
        self.person.fetchDetails().then({ [weak self] data -> Promise<Void> in
            self?.personDetail = data
            
            self?.setupPersonalLabels(title: "Gender", value: data.genderStr, parentView: self?.personalStackViews, view: self?.genderLabels, previousView: self?.nameLabel)
            self?.setupPersonalLabels(title: "Born", value: data.born, parentView: self?.personalStackViews, view: self?.bornLabels, previousView: self?.genderLabels)
            self?.setupPersonalLabels(title: "Died", value: data.died, parentView: self?.personalStackViews, view: self?.diedLabels, previousView: self?.bornLabels)
            self?.setupPersonalLabels(title: "Place Of Birth", value: data.birthPlace, parentView: self?.personalStackViews, view: self?.birthplaceStack, previousView: (self?.diedLabels.isDescendant(of: self!.personalStackViews))! ? self?.diedLabels : self?.bornLabels)
            self?.setupPersonalLabels(title: "Known For", value: data.knownFor, parentView: self?.bodyStackView, view: self?.knownForStack, previousView: self?.birthplaceStack)
            self?.setupPersonalLabels(title: "About", value: data.biography.count <= 0 ? "-" : data.biography, parentView: self?.bodyStackView, view: self?.biographyStack, previousView: self?.knownForStack)
            
            if let notableWorks = data.notableWorks {
                self?.notableWorks.configure(with: notableWorks)
            } else {
                self?.notableWorks.removeFromSuperview()
            }
            return Promise { (fulfill, reject) -> Void in
                fulfill(Void())
            }
        }).always { [weak self] in
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
            self.updateContentSize()
        }
    }
}

extension CreditDetailModal: CreditDetailNotableWorksDelegate {
    func select(media: Media) {
        guard let type = media.mediaType else { return }
        
        if type == .tv {
            let show = Show(id: media.id, name: media.name!, overview: media.overview, posterPath: media.posterPath, firstAirDate: media.firstAirDate!, backdropPath: media.backdropPath)
            let detailVC = ShowDetailViewController(with: show)
            self.dismiss(animated: true) {
                self.delegate?.shouldPush(VC: detailVC)
            }
        } else {
            let movie = Movie(id: media.id, title: media.title!, overview: media.overview, releaseDate: media.releaseDate ?? "", posterPath: media.posterPath, backdropPath: media.backdropPath)
            let detailVC = MovieDetailViewController(with: movie)
            self.dismiss(animated: true) {
                self.delegate?.shouldPush(VC: detailVC)
            }
        }
    }
}
