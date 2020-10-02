//
//  UIImageView+Additions.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 8/4/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher

extension UIImageView {
    public func kfSetImage(with url: URL?, using placeholder: UIImage?, options: KingfisherOptionsInfo? = [.scaleFactor(UIScreen.main.scale), .transition(.fade(1)), .cacheOriginalImage], completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> Void {
        
        kf.indicatorType = .activity
        if completionHandler != nil {
            kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
        } else {
            kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler:  { result in
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
    
    /// Sets Image then returns Promise that contains UIImageColors
    /// - parameter urlString: Image's String URL
    /// - parameter imageView: ImageView to set retrieved Image to
    /// - parameter placeholder: Placeholder Image if no Image was returned from URL
    public static func setImage(urlString: String?, imageView: UIImageView, placeholder: UIImage?) {
        guard let safeUrlString = urlString else { return }
        
        let url = URL(string: safeUrlString)
        let downsample = DownsamplingImageProcessor(size: imageView.bounds.size)
        let options: KingfisherOptionsInfo = [
            .processor(downsample),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
        ]
        imageView.kfSetImage(with: url, using: placeholder, options: options)
    }
    
    /// Sets Image then returns Promise that contains UIImageColors
    /// - parameter urlString: Image's String URL
    /// - parameter imageView: ImageView to set retrieved Image to
    /// - parameter placeholder: Placeholder Image if no Image was returned from URL
    public static func setImageWithPromise(urlString: String?, imageView: UIImageView, placeholder: UIImage?) -> Promise<UIImageColors> {
        let promise = Promise<UIImageColors>.pending()
        
        guard let safeUrlString = urlString else {
            imageView.image = placeholder
            
            if let safeImage = imageView.image {
                safeImage.getColors() { colors in
                    guard let safeColors = colors else { return }
                    promise.fulfill(safeColors)
                }
            }
            
            return promise
        }
        
        let url = URL(string: safeUrlString)
        let downsample = DownsamplingImageProcessor(size: imageView.bounds.size)
        let options: KingfisherOptionsInfo = [
            .processor(downsample),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
        ]
        imageView.kfSetImage(with: url, using: placeholder, options: options) { result in
            switch result {
            case .success:
                if let safeImage = imageView.image {
                    safeImage.getColors() { colors in
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
}
