//
//  BackdropDetail.swift
//  Swift Watch
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
    
    // MARK: - UI Declarations
    lazy var backdrop: UIImageView = {
        let backdrop = UIImageView()
        backdrop.clipsToBounds = true
        backdrop.contentMode = .scaleAspectFill
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        
        return backdrop
    }()
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor]
        
        return gradientLayer
    }()
    
    lazy var poster: UIImageView = {
        let poster = UIImageView()
        poster.clipsToBounds = true
        poster.layer.cornerRadius = 5
        poster.contentMode = .scaleAspectFill
        poster.translatesAutoresizingMaskIntoConstraints = false
        
        let posterConstraints: [NSLayoutConstraint] = [
            poster.widthAnchor.constraint(equalToConstant: 100),
            poster.heightAnchor.constraint(equalToConstant: 150)
        ]
        NSLayoutConstraint.activate(posterConstraints)
        
        return poster
    }()
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 24, weight: .bold))
        
        return title
    }()
    
    lazy var genres: UILabel = {
        let genres = UILabel()
        genres.numberOfLines = 0
        genres.translatesAutoresizingMaskIntoConstraints = false
        genres.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .bold))
        
        return genres
    }()
    
    lazy var runtime: UILabel = {
        let runtime = UILabel()
        runtime.alpha = 0.7
        runtime.translatesAutoresizingMaskIntoConstraints = false
        runtime.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        
        return runtime
    }()
    
    lazy var releaseDate: UILabel = {
        let releaseDate = UILabel()
        releaseDate.alpha = 0.7
        releaseDate.translatesAutoresizingMaskIntoConstraints = false
        releaseDate.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        
        return releaseDate
    }()
    
    lazy var titleStack: UIStackView = {
        let titleStack = UIStackView(arrangedSubviews: [title, releaseDate])
        titleStack.axis = .vertical
        titleStack.setCustomSpacing(35, after: title)
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        return titleStack
    }()
    
    lazy var metaStack: UIStackView = {
        let metaStack = UIStackView(arrangedSubviews: [poster, titleStack])
        metaStack.axis = .horizontal
        metaStack.alignment = .bottom
        metaStack.setCustomSpacing(5, after: poster)
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        
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
        gradientLayer.frame = bounds
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
        // Set Poster
        UIImageView.setImage(urlString: posterURL, imageView: poster, placeholder: placeholder)
        
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
        heightAnchor.constraint(equalToConstant: K.Backdrop.heightConstant).isActive = true
        
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.heightAnchor.constraint(equalTo: heightAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let metsStackConstraints: [NSLayoutConstraint] = [
            metaStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35),
            metaStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            metaStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(metsStackConstraints)
    }
    
    private func setupRuntimeView() {
        titleStack.setCustomSpacing(5, after: releaseDate)
        titleStack.insertArrangedSubview(runtime, at: 2)
    }
    
    private func setupGenresView() {
        titleStack.insertArrangedSubview(genres, at: 1)
        titleStack.setCustomSpacing(0, after: title)
        titleStack.setCustomSpacing(35, after: genres)
    }
}
