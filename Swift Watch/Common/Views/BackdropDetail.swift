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
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 32, weight: .bold))
        
        return title
    }()
    
    lazy var genres: UILabel = {
        let genres = UILabel()
        genres.numberOfLines = 0
        genres.translatesAutoresizingMaskIntoConstraints = false
        genres.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold))
        
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
        let titleStack = UIStackView(arrangedSubviews: [title])
        titleStack.axis = .vertical
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        return titleStack
    }()
    
    init() {
        super.init(frame: .zero)

        addSubview(backdrop)
        addSubview(titleStack)
        addSubview(releaseDate)
        layer.insertSublayer(gradientLayer, at: 1)
        roundCorners([.bottomLeft, .bottomRight], radius: 20)
        
        isSkeletonable = true
        showAnimatedGradientSkeleton()
        
        setupAnchors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Configure
    func configure(url: String? = nil, title _title: String?, genres _genres: String?, runtime _runtime: String?, releaseDate _releaseDate: String?, completionHandler: ((_ colors: UIImageColors) -> Void)? = nil) {
        if _runtime != nil {
           setupRuntimeView()
        }
        
        if _genres != nil {
            setupGenresView()
        }
        
        if let urlString = url {
            setBackdrop(urlString: urlString).then { (colors) in
                DispatchQueue.main.async {
                    self.setupText(title: _title, genres: _genres, runtime: _runtime, releaseDate: _releaseDate)
                    self.setupColor(colors: colors)
                    self.hideSkeleton()
                }
                
                if let safeHandler = completionHandler {
                    safeHandler(colors)
                }
                self.delegate?.didSetupUI(colors: colors)
            }
        } else {
            self.backdrop.image = UIImage(named: "placeholderBackdrop")
            
            if let safeBackdrop = self.backdrop.image {
                safeBackdrop.getColors() { colors in
                    DispatchQueue.main.async {
                        self.setupText(title: _title, genres: _genres, runtime: _runtime, releaseDate: _releaseDate)
                        
                        if let safeColors = colors {
                            self.setupColor(colors: safeColors)
                        }
                        self.hideSkeleton()
                    }
                    
                    if let safeColors = colors {
                        if let safeHandler = completionHandler {
                            safeHandler(safeColors)
                        }
                        self.delegate?.didSetupUI(colors: safeColors)
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Functions
extension BackdropDetail {
    private func setBackdrop(urlString: String) -> Promise<UIImageColors> {
        let promise = Promise<UIImageColors>.pending()
        
        let url = URL(string: urlString)
        let downsample = DownsamplingImageProcessor(size: bounds.size)
        
        backdrop.kfSetImage(with: url, using: UIImage(named: "placeholderBackdrop"), processor: downsample) { result in
            switch result {
            case .success:
                if let backdropImage = self.backdrop.image {
                    backdropImage.getColors() { colors in
                        guard let safeColors = colors else { return }
                        promise.fulfill(safeColors)
                    }
                }
                break
            case .failure(let e):
                promise.reject(e)
                break
            }
            
        }
        
        return promise
    }
    
    private func setupText(title _title: String?, genres _genres: String?, runtime _runtime: String?, releaseDate _releaseDate: String?) {
        self.title.text = _title
        self.genres.text = _genres
        
        if let safeRuntime = _runtime {
            runtime.text = safeRuntime
        }
        
        var releaseMonth: String?
        var releaseDay: Int?
        var releaseYear: Int?
        if let dateString = _releaseDate {
            let date = Date(dateString, with: "YYYY-MM-dd")
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "LLL"
            releaseMonth = monthFormatter.string(from: date)
            
            let calendar = Calendar.current.dateComponents([.day, .year], from: date)
            releaseDay = calendar.day
            releaseYear = calendar.year
        }
        
        if releaseMonth != nil && releaseYear != nil && releaseDay != nil {
            releaseDate.text = "\(releaseMonth!) \(releaseDay!), \(releaseYear!)"
        }
    }
    
    private func setupColor(colors: UIImageColors) {
        title.textColor = colors.primary
        genres.textColor = colors.secondary
        runtime.textColor = colors.secondary
        releaseDate.textColor = colors.secondary
        
        gradientLayer.colors = [UIColor.clear.cgColor, colors.background.cgColor]
        
        backdrop.hideSkeleton(transition: .crossDissolve(0.25))
    }
    
    private func setupAnchors() {
        heightAnchor.constraint(equalToConstant: K.BackdropDetail.heightConstant).isActive = true
        
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.heightAnchor.constraint(equalTo: heightAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let releaseDateConstraints: [NSLayoutConstraint] = [
            releaseDate.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -35),
            releaseDate.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            releaseDate.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(releaseDateConstraints)
        
        let titleStackConstraints: [NSLayoutConstraint] = [
            titleStack.bottomAnchor.constraint(equalTo: releaseDate.topAnchor, constant: -35),
            titleStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(titleStackConstraints)
    }
    
    private func setupRuntimeView() {
        insertSubview(runtime, aboveSubview: releaseDate)
        let runtimeConstraints: [NSLayoutConstraint] = [
            runtime.topAnchor.constraint(equalTo: releaseDate.bottomAnchor, constant: 5),
            runtime.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            runtime.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(runtimeConstraints)
    }
    
    private func setupGenresView() {
        titleStack.insertArrangedSubview(genres, at: 1)
    }
}
