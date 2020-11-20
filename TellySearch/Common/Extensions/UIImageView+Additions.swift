//
//  UIImageView+Additions.swift
//  TellySearch
//
//  Created by Victor Ragojos on 8/4/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Promises
import Kingfisher
import OctreePalette

extension UIImageView {
    public func kfSetImage(with url: URL?, using placeholder: UIImage?, options: KingfisherOptionsInfo? = [.scaleFactor(UIScreen.main.scale), .transition(.fade(1)), .cacheOriginalImage], completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> Void {
        
        kf.indicatorType = .activity
        if completionHandler != nil {
            kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
        } else {
            kf.setImage(with: url, placeholder: placeholder, options: options, completionHandler:  { [weak self] result in
                switch result {
                case .success:
                    return
                case .failure(let e):
                    // If Image actually failed to Fetch
                    if !e.isTaskCancelled && !e.isNotCurrentTask {
                        self?.image = placeholder
                    }
                    return
                }
            })
        }
    }
    
    /// Sets Image then returns Promise that contains ColorTheme
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
    
    /// Sets Image then returns Promise that contains ColorTheme
    /// - parameter urlString: Image's String URL
    /// - parameter imageView: ImageView to set retrieved Image to
    /// - parameter placeholder: Placeholder Image if no Image was returned from URL
    public static func setImageWithPromise(urlString: String?, imageView: UIImageView, placeholder: UIImage?) -> Promise<ColorTheme> {
        let tolerance: Int = 50
        let type: ColorThemeType = .smallText
        let promise = Promise<ColorTheme>.pending()
        
        guard let safeUrlString = urlString else {
            imageView.image = placeholder
            
            if let safeImage = imageView.image {
                safeImage.getColorTheme(tolerance: tolerance, type: type) { colors in
                    promise.fulfill(colors)
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
                    safeImage.getColorTheme(tolerance: tolerance, type: type) { colors in
                        promise.fulfill(colors)
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
