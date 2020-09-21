//
//  UIImageView+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/4/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    func kfSetImage(with url: URL?, using placeholder: UIImage?, options: KingfisherOptionsInfo? = [.scaleFactor(UIScreen.main.scale), .transition(.fade(1)), .cacheOriginalImage], completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> Void {
        
        self.kf.indicatorType = .activity
        
        if completionHandler != nil {
            self.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
        } else {
            self.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler:  { result in
                switch result {
                case .success:
                    return
                case .failure:
                    self.image = placeholder
                    return
                }
            })
        }
    }
}
