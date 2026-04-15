import UIKit

enum DSTextStyle {
    case titleLarge
    case titleScreen
    case body
    case bodyMedium
    case caption
    case captionSecondary
    case errorField
    case errorBanner
    case listTitle
    case listSubtitle

    var font: UIFont {
        switch self {
        case .titleLarge: return DS.Typography.titleLarge()
        case .titleScreen: return DS.Typography.titleScreen()
        case .body: return DS.Typography.body()
        case .bodyMedium: return DS.Typography.bodyMedium()
        case .caption: return DS.Typography.caption()
        case .captionSecondary: return DS.Typography.caption()
        case .errorField: return DS.Typography.captionSmall()
        case .errorBanner: return DS.Typography.body()
        case .listTitle: return DS.Typography.listTitle()
        case .listSubtitle: return DS.Typography.listSubtitle()
        }
    }

    var textColor: UIColor {
        switch self {
        case .titleLarge, .titleScreen, .body, .bodyMedium, .listTitle:
            return DS.Colors.textPrimary
        case .caption, .captionSecondary, .listSubtitle:
            return DS.Colors.textSecondary
        case .errorField, .errorBanner:
            return DS.Colors.error
        }
    }
}

extension UILabel {
    func ds_apply(_ style: DSTextStyle) {
        font = style.font
        textColor = style.textColor
    }
}

extension UITextField {
    func ds_applyInputTypography() {
        font = DS.Typography.body()
        textColor = DS.Colors.textPrimary
    }
}
