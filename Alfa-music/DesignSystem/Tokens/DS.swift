import UIKit

enum DS {

    enum Colors {
        static var background: UIColor { .systemBackground }
        static var elevated: UIColor { .secondarySystemBackground }
        static var primary: UIColor { .systemBlue }
        static var textPrimary: UIColor { .label }
        static var textSecondary: UIColor { .secondaryLabel }
        static var textOnPrimary: UIColor { .white }
        static var error: UIColor { .systemRed }
        static var borderSubtle: UIColor { .separator }
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
    }

    enum Typography {
        static let titleLarge = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let titleScreen = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let bodyMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let caption = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let captionSmall = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let captionMonospaced = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        static let listTitle = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let listSubtitle = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    enum Layout {
        static let textFieldHeight: CGFloat = 48
        static let buttonHeight: CGFloat = 48

        enum Auth {
            static let titleToFieldsSpacing: CGFloat = Spacing.s
            static let fieldsToErrorSpacing: CGFloat = Spacing.xs
            static let horizontalInset: CGFloat = Spacing.l
            static let fieldsToButtonSpacing : CGFloat = Spacing.l
        }

        enum FormField {
            static let labelToInputSpacing: CGFloat = 0
            static let inputToErrorSpacing: CGFloat = Spacing.xs
        }

        enum AlbumCell {
            static let artworkSize: CGFloat = 56
            static let verticalInset: CGFloat = Spacing.s
            static let textHorizontalGap: CGFloat = Spacing.s
        }

        enum CatalogList {
            static let estimatedRowHeight: CGFloat = AlbumCell.artworkSize + AlbumCell.verticalInset * 2
            static let separatorLeadingInset: CGFloat = Spacing.m + AlbumCell.artworkSize + Spacing.m
        }

        enum TrackDetail {
            static let stateHorizontalInset: CGFloat = Spacing.l
            static let retryTopSpacing: CGFloat = Spacing.s
            static let trackCellHorizontalInset: CGFloat = Spacing.m
            static let trackCellVerticalInset: CGFloat = Spacing.s
            static let trackCellRightGap: CGFloat = Spacing.s
            static let trackCellTitleSubtitleSpacing: CGFloat = Spacing.xs
        }
    }

    enum Shadow {
        static func applyCardShadow(to layer: CALayer) {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.08
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 6
            layer.masksToBounds = false
        }
    }
}
