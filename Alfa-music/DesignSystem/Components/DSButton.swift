import UIKit

final class DSButton: UIButton {

    enum Style {
        case primary
        case secondary
    }

    private let dsStyle: Style

    init(style: Style) {
        self.dsStyle = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = DS.Radius.m
        layer.masksToBounds = true
        titleLabel?.font = DS.Typography.bodyMedium()
        heightAnchor.constraint(equalToConstant: DS.Layout.buttonHeight).isActive = true
        applyStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet { applyStyle() }
    }

    private func applyStyle() {
        switch dsStyle {
        case .primary:
            backgroundColor = isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.35)
            setTitleColor(DS.Colors.textOnPrimary, for: .normal)
            setTitleColor(DS.Colors.textOnPrimary.withAlphaComponent(0.7), for: .highlighted)
        case .secondary:
            backgroundColor = .clear
            setTitleColor(isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.35), for: .normal)
            setTitleColor(DS.Colors.primary.withAlphaComponent(0.6), for: .highlighted)
        }
    }
}
