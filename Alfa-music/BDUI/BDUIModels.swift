import UIKit

enum BDUIActionDTO: Decodable {
    case event(name: String, payload: [String: String]?)

    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case name
        case payload
    }

    private enum ActionType: String, Decodable {
        case event
        case callback
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        switch type {
        case .event:
            self = .event(
                name: try container.decode(String.self, forKey: .name),
                payload: try container.decodeIfPresent([String: String].self, forKey: .payload)
            )
        case .callback:
            self = .event(
                name: try container.decode(String.self, forKey: .id),
                payload: nil
            )
        }
    }
}

enum BDUIComponentType: String, Decodable {
    case scroll
    case vStack
    case hStack
    case container
    case image
    case label
    case button
    case textField
    case spacer
    case state
}

struct BDUILabelContentDTO: Decodable {
    let text: String
    let textStyle: BDUITextStyleToken
    let color: BDUIColorToken?
    let alignment: String?
    let numberOfLines: Int?
}

struct BDUIButtonContentDTO: Decodable {
    let title: String
    let style: BDUIButtonStyleToken
    let isEnabled: Bool?
}

struct BDUIStackContentDTO: Decodable {
    let spacing: BDUISpacingToken?
    let padding: BDUISpacingToken?
    let backgroundColor: BDUIColorToken?
    let cornerRadius: BDUICornerRadiusToken?
}

struct BDUIContainerContentDTO: Decodable {
    let backgroundColor: BDUIColorToken?
    let padding: BDUISpacingToken?
    let cornerRadius: BDUICornerRadiusToken?
}

struct BDUIImageContentDTO: Decodable {
    let url: String?
    let width: Double?
    let height: Double?
    let cornerRadius: BDUICornerRadiusToken?
    let contentMode: BDUIImageContentModeToken?
}

struct BDUITextFieldContentDTO: Decodable {
    let title: String
    let placeholder: String
    let text: String?
    let errorMessage: String?
    let isSecure: Bool?
}

struct BDUISpacerContentDTO: Decodable {
    let height: Double?
}

struct BDUIStateContentDTO: Decodable {
    let style: BDUIStateStyleToken
    let title: String?
    let message: String?
    let actionTitle: String?
}

enum BDUIContentDTO {
    case label(BDUILabelContentDTO)
    case button(BDUIButtonContentDTO)
    case stack(BDUIStackContentDTO)
    case container(BDUIContainerContentDTO)
    case image(BDUIImageContentDTO)
    case textField(BDUITextFieldContentDTO)
    case spacer(BDUISpacerContentDTO)
    case state(BDUIStateContentDTO)
}

struct BDUINodeDTO: Decodable {
    let id: String
    let type: BDUIComponentType
    let content: BDUIContentDTO?
    let subviews: [BDUINodeDTO]
    let action: BDUIActionDTO?
    let isVisible: Bool

    init(
        id: String,
        type: BDUIComponentType,
        content: BDUIContentDTO?,
        subviews: [BDUINodeDTO],
        action: BDUIActionDTO?,
        isVisible: Bool
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.subviews = subviews
        self.action = action
        self.isVisible = isVisible
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case content
        case subviews
        case action
        case isVisible
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(BDUIComponentType.self, forKey: .type)
        subviews = try container.decodeIfPresent([BDUINodeDTO].self, forKey: .subviews) ?? []
        action = try container.decodeIfPresent(BDUIActionDTO.self, forKey: .action)
        isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true

        switch type {
        case .label:
            content = .label(try container.decode(BDUILabelContentDTO.self, forKey: .content))
        case .button:
            content = .button(try container.decode(BDUIButtonContentDTO.self, forKey: .content))
        case .vStack, .hStack, .scroll:
            content = .stack(
                try container.decodeIfPresent(BDUIStackContentDTO.self, forKey: .content)
                    ?? BDUiDefaults.stack
            )
        case .container:
            content = .container(
                try container.decodeIfPresent(BDUIContainerContentDTO.self, forKey: .content)
                    ?? BDUiDefaults.container
            )
        case .image:
            content = .image(
                try container.decodeIfPresent(BDUIImageContentDTO.self, forKey: .content)
                    ?? BDUIImageContentDTO(
                        url: nil,
                        width: nil,
                        height: nil,
                        cornerRadius: nil,
                        contentMode: nil
                    )
            )
        case .textField:
            content = .textField(try container.decode(BDUITextFieldContentDTO.self, forKey: .content))
        case .spacer:
            content = .spacer(
                try container.decodeIfPresent(BDUISpacerContentDTO.self, forKey: .content)
                    ?? BDUISpacerContentDTO(height: nil)
            )
        case .state:
            content = .state(try container.decode(BDUIStateContentDTO.self, forKey: .content))
        }
    }
}

struct BDUIScreenDTO: Decodable {
    let root: BDUINodeDTO
}

private enum BDUiDefaults {
    static let stack = BDUIStackContentDTO(
        spacing: nil,
        padding: nil,
        backgroundColor: nil,
        cornerRadius: nil
    )
    static let container = BDUIContainerContentDTO(
        backgroundColor: nil,
        padding: nil,
        cornerRadius: nil
    )
}

enum BDUIColorToken: String, Decodable {
    case background
    case elevated
    case primary
    case textPrimary
    case textSecondary
    case error
    case borderSubtle
    case clear

    var uiColor: UIColor {
        switch self {
        case .background: return DS.Colors.background
        case .elevated: return DS.Colors.elevated
        case .primary: return DS.Colors.primary
        case .textPrimary: return DS.Colors.textPrimary
        case .textSecondary: return DS.Colors.textSecondary
        case .error: return DS.Colors.error
        case .borderSubtle: return DS.Colors.borderSubtle
        case .clear: return .clear
        }
    }
}

enum BDUISpacingToken: String, Decodable {
    case xs
    case s
    case m
    case l
    case xl

    var value: CGFloat {
        switch self {
        case .xs: return DS.Spacing.xs
        case .s: return DS.Spacing.s
        case .m: return DS.Spacing.m
        case .l: return DS.Spacing.l
        case .xl: return DS.Spacing.xl
        }
    }
}

enum BDUICornerRadiusToken: String, Decodable {
    case s
    case m
    case l

    var value: CGFloat {
        switch self {
        case .s: return DS.Radius.s
        case .m: return DS.Radius.m
        case .l: return DS.Radius.l
        }
    }
}

enum BDUITextStyleToken: String, Decodable {
    case titleLarge
    case titleScreen
    case body
    case bodyMedium
    case caption
    case captionSecondary
    case errorBanner
    case listTitle
    case listSubtitle

    var style: DSTextStyle {
        switch self {
        case .titleLarge: return .titleLarge
        case .titleScreen: return .titleScreen
        case .body: return .body
        case .bodyMedium: return .bodyMedium
        case .caption: return .caption
        case .captionSecondary: return .captionSecondary
        case .errorBanner: return .errorBanner
        case .listTitle: return .listTitle
        case .listSubtitle: return .listSubtitle
        }
    }
}

enum BDUIButtonStyleToken: String, Decodable {
    case primary
    case secondary

    var dsStyle: DSButton.Style {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        }
    }
}

enum BDUIStateStyleToken: String, Decodable {
    case hidden
    case loading
    case empty
    case error
}

enum BDUIImageContentModeToken: String, Decodable {
    case scaleAspectFill
    case scaleAspectFit

    var value: UIView.ContentMode {
        switch self {
        case .scaleAspectFill: return .scaleAspectFill
        case .scaleAspectFit: return .scaleAspectFit
        }
    }
}
