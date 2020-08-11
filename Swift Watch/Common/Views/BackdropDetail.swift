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
        backdrop.roundCorners([.bottomLeft, .bottomRight], radius: 20)
        
        // Setup Skeleton
        DispatchQueue.main.async {
            backdrop.isSkeletonable = true
            backdrop.showAnimatedGradientSkeleton(transition: .crossDissolve(0.25))            
        }
        
        return backdrop
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
        let titleStack = UIStackView(arrangedSubviews: [title, genres])
        titleStack.axis = .vertical
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        return titleStack
    }()
    
    init() {
        super.init(frame: .zero)

        addSubview(backdrop)
        addSubview(titleStack)
        addSubview(runtime)
        addSubview(releaseDate)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupAnchors()
    }
    
    // MARK: - Configure
    func configure(url: String?, title _title: String?, genres _genres: String?, runtime _runtime: String?, releaseDate _releaseDate: String?) {
        if let urlString = url {
            setBackdrop(urlString: urlString).then { (colors) in
                
                DispatchQueue.main.async {
                    self.setupText(title: _title, genres: _genres, runtime: _runtime, releaseDate: _releaseDate)
                    self.setupColor(colors: colors)
                }
                
                self.delegate?.didSetupUI(colors: colors)
            }
        } else {
            self.backdrop.image = UIImage(named: "placeholderBackdrop")
            
            DispatchQueue.main.async {
                if let safeBackdrop = self.backdrop.image {
                    safeBackdrop.getColors() { colors in
                        DispatchQueue.main.async {
                            self.setupText(title: _title, genres: _genres, runtime: _runtime, releaseDate: _releaseDate)
                            
                            if let safeColors = colors {
                                self.setupColor(colors: safeColors)
                            }
                        }
                        
                        if let safeColors = colors {
                            self.delegate?.didSetupUI(colors: safeColors)
                        }
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
        } else {
            runtime.text = "Runtime not provided"
        }
        
        var releaseMonth: String?
        var releaseYear: Int?
        if let dateString = _releaseDate {
            let date = Date(dateString, with: "YYYY-MM-DD")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLL"
            releaseMonth = dateFormatter.string(from: date)
            releaseYear = Calendar.current.component(.year, from: date)
        }
        
        if releaseMonth != nil && releaseYear != nil {
            releaseDate.text = "\(releaseMonth!) \(releaseYear!)"
        }
    }
    
    private func setupColor(colors: UIImageColors) {
        title.textColor = colors.primary
        genres.textColor = colors.secondary
        runtime.textColor = colors.secondary
        releaseDate.textColor = colors.secondary
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.backdrop.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, colors.background.cgColor]
        backdrop.layer.insertSublayer(gradientLayer, at: 0)
        
        backdrop.hideSkeleton(transition: .crossDissolve(0.25))
    }
    
    private func setupAnchors() {
        heightAnchor.constraint(equalToConstant: K.BackdropDetail.heightConstant).isActive = true
        
        let backdropConstraints: [NSLayoutConstraint] = [
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.widthAnchor.constraint(equalTo: widthAnchor),
            backdrop.heightAnchor.constraint(equalTo: heightAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        NSLayoutConstraint.activate(backdropConstraints)
        
        let releaseDateConstraints: [NSLayoutConstraint] = [
            releaseDate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            releaseDate.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(releaseDateConstraints)
        
        let runtimeConstraints: [NSLayoutConstraint] = [
            runtime.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            runtime.topAnchor.constraint(equalTo: releaseDate.bottomAnchor, constant: 5)
        ]
        NSLayoutConstraint.activate(runtimeConstraints)
        
        let titleStackConstraints: [NSLayoutConstraint] = [
            titleStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleStack.bottomAnchor.constraint(equalTo: releaseDate.topAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(titleStackConstraints)
    }
}
