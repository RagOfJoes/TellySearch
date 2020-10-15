//
//  Poster.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/26/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class Poster: UIImageView {
    // MARK: - Internal Properties
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private let placeholder: UIImage? = UIImage(named: "placeholderPoster")
    
    // MARK: - Life Cycle
    init(with string: String? = nil) {
        super.init(frame: .zero)
        clipsToBounds = true
        isSkeletonable = true
        layer.cornerRadius = 5
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        
        widthConstraint = widthAnchor.constraint(equalToConstant: T.Width.Poster)
        heightConstraint = heightAnchor.constraint(equalToConstant: T.Height.Poster)
        let constraints: [NSLayoutConstraint] = [
            widthConstraint,
            heightConstraint
        ]
        NSLayoutConstraint.activate(constraints)

        guard let safeString = string else { image = placeholder; return }
        guard let url = URL(string: K.URL.Poster + safeString) else { image = placeholder; return }
        kfSetImage(with: url, using: placeholder)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        widthConstraint.constant = T.Width.Poster
        heightConstraint.constant = T.Height.Poster
    }
    
    func configure(with string: String) {
        guard let url = URL(string: K.URL.Poster + string) else { return }
        kfSetImage(with: url, using: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
