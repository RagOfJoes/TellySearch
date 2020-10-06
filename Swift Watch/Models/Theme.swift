//
//  Theme.swift
//  Swift Watch
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
        static let Backdrop: CGFloat = UIScreen.main.bounds.width
        static var Poster: CGFloat {
            get {
                let screen = UIScreen.main.bounds
                let minWidth = screen.width > 500 ? screen.width / 6.25 : screen.width / 3
                
                let numberOfCells: CGFloat = UIScreen.main.bounds.width / minWidth
                let width: CGFloat = floor((numberOfCells / floor(numberOfCells)) * minWidth)
                
                return width
            }
        }
        
        // MARK: - Cell
        static func Cell(type: CellType) -> CGFloat {
            let screen = UIScreen.main.bounds
            switch type {
            case .Featured:
                let minWidth = screen.width > 500 ? screen.width / 2 : screen.width / 1.25
                let numberOfCells: CGFloat = screen.width / minWidth
                let width: CGFloat = (numberOfCells / numberOfCells) * minWidth
                
                // Account for the CollectionView insets
                return width - 40
            default:
                return Poster
            }
        }
    }
    
    // MARK: - Height
    struct Height {
        static let Backdrop: CGFloat = 400
        static var Poster: CGFloat {
            get {
                let ratio: CGFloat = (27 / 40)
                return .getHeight(with: T.Width.Poster, using: ratio)
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
                let primaryHeight = placeholder.height(withConstrainedWidth: T.Width.Poster, font: primaryFont) * 2
                let secondaryHeight = placeholder.height(font: secondaryFont) * 2
                
                return primaryHeight + secondaryHeight + Poster + 5
            default:
                let primaryHeight = placeholder.height(withConstrainedWidth: T.Width.Poster, font: primaryFont) * 2

                return primaryHeight + T.Height.Poster + 5
            }
        }
    }
}
