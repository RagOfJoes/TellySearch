//
//  PosterImageView.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/26/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class PosterImageView: UIImageView {
    static let placeholder: UIImage? = UIImage(named: "placeholderPoster")
    
    init(with string: String?) {
        super.init(frame: .zero)
        clipsToBounds = true
        layer.cornerRadius = 5
        contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: K.Poster.width),
            heightAnchor.constraint(equalToConstant: K.Poster.height)
        ]
        NSLayoutConstraint.activate(constraints)

        guard let safeString = string else { image = PosterImageView.placeholder; return }
        guard let url = URL(string: K.Credits.profileURL + safeString) else { image = PosterImageView.placeholder; return }
        kfSetImage(with: url, using: PosterImageView.placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
