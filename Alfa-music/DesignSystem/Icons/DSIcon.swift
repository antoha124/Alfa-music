import UIKit

enum DSIcon {

    enum Size: CGFloat {
        case s = 16
        case m = 24
        case l = 32
    }

    static func symbol(
        _ systemName: String,
        size: Size,
        weight: UIImage.SymbolWeight = .regular
    ) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size.rawValue, weight: weight)
        return UIImage(systemName: systemName)?.withConfiguration(config)
    }

    static func template(_ systemName: String, size: Size, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        symbol(systemName, size: size, weight: weight)?.withRenderingMode(.alwaysTemplate)
    }

    enum Name {
        static let tray = "tray"
        static let exclamationTriangle = "exclamationmark.triangle"
        static let musicNote = "music.note"
        static let photo = "photo"
    }
}
