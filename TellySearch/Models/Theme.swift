//
//  Theme.swift
//  TellySearch
//
//  Created by Victor Ragojos on 10/4/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

struct T {
    // MARK: - Types
    enum CellType {
        case Regular
        case Featured
        case RegularSecondary
    }
    
    static var isIpad = UIDevice.current.userInterfaceIdiom == .pad
    static var isFullScreen: Bool {
        get {
            return UIApplication.shared.keyWindow?.frame == UIScreen.main.bounds
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // MARK: - Internal Properties
        var font: UIFont
        static let Sizes: [Variant: CGFloat] = [
            .HeadingOne: 22,
            .HeadingTwo: 20,
            
            .Title: 18,
            .Subtitle: 13,
            
            .Body: 14
        ]
        static let Weights: [Variant: UIFont.Weight] = [
            .HeadingOne: .bold,
            .HeadingTwo: .bold,
            
            .Title: .bold,
            .Subtitle: .semibold,
            
            .Body: .medium
        ]
        enum Variant {
            case HeadingOne
            case HeadingTwo
            
            case Title
            case Subtitle
            
            case Body
        }
        
        // MARK: - Internal Methods
        public static func generateFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
            return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))
        }
        
        // MARK: - Constructor
        init(variant: T.Typography.Variant, weight: UIFont.Weight? = nil) {
            let size: CGFloat = T.Typography.Sizes[variant] ?? 14
            let _weight: UIFont.Weight = weight ?? T.Typography.Weights[variant] ?? .medium
                        
            switch variant {
            case .HeadingOne:
                font = T.Typography.generateFont(size: size, weight: _weight)
                break
            case .HeadingTwo:
                font = T.Typography.generateFont(size: size, weight: _weight)
                break
            case .Title:
                font = T.Typography.generateFont(size: size, weight: _weight)
                break
            case .Subtitle:
                font = T.Typography.generateFont(size: size, weight: _weight)
                break
            default:
                font = T.Typography.generateFont(size: size, weight: _weight)
            }
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        enum Size {
            case small
            case medium
            case large
        }
        
        static func Vertical(size: Size = .medium) -> CGFloat {
            switch size {
            case .large:
                return 35
            case .small:
                return 5
            default:
                return 10
            }
        }
        
        static func Horizontal(size: Size = .medium) -> CGFloat {
            switch size {
            case .large:
                return 40
            case .small:
                return 10
            default:
                return 20
            }
        }
    }
    
    // MARK: - Width
    struct Width {
        static let Backdrop: CGFloat = UIApplication.shared.windows[0].bounds.width
        static var Episode: CGFloat {
            get {
                return UIApplication.shared.windows[0].bounds.width - 40
            }
        }
        static var Poster: CGFloat {
            get {
                let screen = UIApplication.shared.windows[0].bounds
                let maxWidth: CGFloat = 170
                let minWidth = screen.width / 3
                let numberOfCells: CGFloat = screen.width / minWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * minWidth)
                
                if width > maxWidth {
                    return maxWidth
                }
                return width
            }
        }
        
        // MARK: - Cell
        static func Cell(type: CellType) -> CGFloat {
            let screen =  UIApplication.shared.windows[0].bounds
            switch type {
            case .Featured:
                let maxWidth: CGFloat = 512
                let minWidth =  screen.width / 1.1
                let numberOfCells: CGFloat = screen.width / minWidth
                let width: CGFloat = (numberOfCells / numberOfCells) * minWidth
                if width > maxWidth {
                    return maxWidth - 40
                }
                // Account for the CollectionView insets
                return width - 40
            default:
                let maxWidth: CGFloat = 170
                let minWidth = screen.width / 3
                let numberOfCells: CGFloat = screen.width / minWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * minWidth)
                
                if width > maxWidth {
                    return maxWidth
                }
                return width
            }
        }
    }
    
    // MARK: - Height
    struct Height {
        static let Backdrop: CGFloat = 400
        static var Episode: CGFloat {
            get {
                return .getHeight(with: T.Width.Episode, using: (16 / 9))
            }
        }
        static var Poster: CGFloat {
            get {
                let ratio: CGFloat = (27 / 40)
                return .getHeight(with: T.Width.Poster, using: ratio)
            }
        }
        static var Season: CGFloat {
            get {
                let ratio: CGFloat = (16 / 9)
                let constrainedWidth: CGFloat = T.Width.Episode
                
                let backdropHeight: CGFloat = .getHeight(with: constrainedWidth, using: ratio)
                
                let nameFont: UIFont = T.Typography(variant: .Body, weight: .bold).font
                let nameHeight: CGFloat = "".height(withConstrainedWidth: constrainedWidth, font: nameFont) * 2
                
                let airDateFont: UIFont = T.Typography(variant: .Subtitle).font
                let airDateHeight: CGFloat = "".height(withConstrainedWidth: constrainedWidth, font: airDateFont)
                
                let spacing: CGFloat = T.Spacing.Vertical(size: .small)
                
                return backdropHeight + nameHeight + airDateHeight + spacing
            }
        }
        
        // MARK: - Cell
        static func Cell(type: CellType) -> CGFloat {
            // Placeholder Text
            let placeholder = "Lorem"
            let primaryFont = T.Typography(variant: .Body).font
            let secondaryFont = T.Typography(variant: .Subtitle).font
            switch type {
            case .Featured:
                let primaryHeight = placeholder.height(font: primaryFont) * 2
                
                let ratio: CGFloat = (16 / 9)
                let height: CGFloat = .getHeight(with: T.Width.Cell(type: .Featured), using: ratio)
                
                return height + primaryHeight + 5
            case .RegularSecondary:
                let primaryHeight = placeholder.height(withConstrainedWidth: T.Width.Cell(type: .RegularSecondary), font: primaryFont) * 2
                let secondaryHeight = placeholder.height(font: secondaryFont) * 2

                let ratio: CGFloat = (27 / 40)
                let imageHeight: CGFloat = .getHeight(with: T.Width.Cell(type: type), using: ratio)
                
                return primaryHeight + secondaryHeight + imageHeight + 5
            default:
                let primaryHeight = placeholder.height(withConstrainedWidth: T.Width.Cell(type: .Regular), font: primaryFont) * 2
                let ratio: CGFloat = (27 / 40)
                let imageHeight: CGFloat = .getHeight(with: T.Width.Cell(type: type), using: ratio)
                
                return primaryHeight + imageHeight + 5
            }
        }
    }
}
