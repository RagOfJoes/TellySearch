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
    func kfSetImage(with url: URL?, using placeholder: UIImage?) -> Void {
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage,
        ]) { result in
            switch result {
            case .failure:
                return
            case .success(_):
                return
            }
        }
    }
    
    func kfSetImage(with url: URL?, using placeholder: UIImage?, processor: ImageProcessor, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> Void {
        self.kf.indicatorType = .activity
        
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
        ]
        
        self.kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }
}
