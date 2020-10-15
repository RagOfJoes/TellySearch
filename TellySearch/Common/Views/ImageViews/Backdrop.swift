//
//  BackdropDetail.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/6/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher
import SkeletonView

protocol BackdropDetailDelegate: AnyObject {
    func didSetupUI(colors: UIImageColors)
}

class BackdropDetail: UIView {
    weak var delegate: BackdropDetailDelegate?
    private var posterWidthConstraint: NSLayoutConstraint!
    private var posterHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Declarations
    private lazy var backdrop: UIImageView = {
        let backdrop = UIImageView()
        backdrop.clipsToBounds = true
        backdrop.contentMode = .scaleAspectFill
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        return backdrop
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor]
        
        return gradientLayer
    }()
    private let poster: Poster = Poster()
    private lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.font = T.Typography(variant: .HeadingOne).font
        title.translatesAutoresizingMaskIntoConstraints = false
        
        return title
    }()
    
    private lazy var genres: UILabel = {
        let genres = UILabel()
        genres.numberOfLines = 0
        genres.font = T.Typography(variant: .Body).font
        genres.translatesAutoresizingMaskIntoConstraints = false
        
        return genres
    }()
    
    private lazy var runtime: UILabel = {
        let runtime = UILabel()
        runtime.alpha = 0.7
        runtime.font = T.Typography(variant: .Body).font
        runtime.translatesAutoresizingMaskIntoConstraints = false
        
        return runtime
    }()
    
    private lazy var releaseDate: UILabel = {
        let releaseDate = UILabel()
        releaseDate.alpha = 0.7
        releaseDate.font = T.Typography(variant: .Body).font
        releaseDate.translatesAutoresizingMaskIntoConstraints = false
        
        return releaseDate
    }()
    
    private lazy var titleStack: UIStackView = {
        let titleStack = UIStackView(arrangedSubviews: [title, releaseDate])
        titleStack.axis = .vertical
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.setCustomSpacing(T.Spacing.Vertical(size: .large), after: title)
        
        return titleStack
    }()
    
    private lazy var metaStack: UIStackView = {
        let metaStack = UIStackView(arrangedSubviews: [poster, titleStack])
        metaStack.axis = .horizontal
        metaStack.alignment = .bottom
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.setCustomSpacing(T.Spacing.Vertical(size: .small), after: poster)
        
        return metaStack
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backdrop)
        addSubview(metaStack)
        layer.insertSublayer(gradientLayer, at: 1)
        
        setupAnchors()
        
        isSkeletonable = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: T.Height.Backdrop)
    }
    
    // MARK: - Configure
    func configure(backdropURL: String? = nil, posterURL: String? = nil, title: String?, genres: String?, runtime: String?, releaseDate: String?, completionHandler: ((_ colors: UIImageColors) -> Void)? = nil) {
        if runtime != nil {
            setupRuntimeView()
        }
        
        if genres != nil {
            setupGenresView()
        }
        
        let placeholder = UIImage(named: "placeholderPoster")
        if posterURL != nil {
            poster.configure(with: posterURL!)
        }
        // Sets Backdrop
        UIImageView.setImageWithPromise(urlString: backdropURL, imageView: backdrop, placeholder: placeholder).then { (colors) in
            DispatchQueue.main.async {
                self.setupText(title: title, genres: genres, runtime: runtime, releaseDate: releaseDate)
                self.setupColor(colors: colors)
            }
            
            if let safeHandler = completionHandler {
                safeHandler(colors)
            }
            self.delegate?.didSetupUI(colors: colors)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Functions
extension BackdropDetail {
    private func setupText(title _title: String?, genres _genres: String?, runtime _runtime: String?, releaseDate _releaseDate: String?) {
        title.text = _title
        genres.text = _genres
        
        if let safeRuntime = _runtime {
            runtime.text = safeRuntime
        }
        
        if _releaseDate != nil {
            let dateString = _releaseDate?.formatDate(format: "YYYY-MM-dd", formatter: { (month, day, year) -> String in
                return "\(month) \(day), \(year)"
            })
            
            releaseDate.text = dateString ?? "-"
        } else {
            releaseDate.text = "-"
        }
    }
    
    private func setupColor(colors: UIImageColors) {
        title.textColor = colors.primary
        genres.textColor = colors.secondary
        runtime.textColor = colors.secondary
        releaseDate.textColor = colors.secondary
        
        gradientLayer.colors = [UIColor.clear.cgColor, colors.background.cgColor]
    }
    
    private func setupAnchors() {
        let height: CGFloat = T.Height.Backdrop + T.Spacing.Vertical(size: .large)
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdrop.heightAnchor.constraint(equalToConstant: T.Height.Backdrop)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let metsStackConstraints: [NSLayoutConstraint] = [
            metaStack.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: T.Spacing.Vertical(size: .large)),
            metaStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: T.Spacing.Horizontal()),
            metaStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -T.Spacing.Horizontal())
        ]
        NSLayoutConstraint.activate(metsStackConstraints)
    }
    
    private func setupRuntimeView() {
        titleStack.insertArrangedSubview(runtime, at: 2)
        titleStack.setCustomSpacing(T.Spacing.Vertical(size: .small), after: releaseDate)
    }
    
    private func setupGenresView() {
        titleStack.insertArrangedSubview(genres, at: 1)
        titleStack.setCustomSpacing(0, after: title)
        titleStack.setCustomSpacing(T.Spacing.Vertical(size: .large), after: genres)
    }
}
