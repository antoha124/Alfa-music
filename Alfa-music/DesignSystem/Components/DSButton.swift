import UIKit

final class DSButton: UIView {

    enum Style {
        case primary
        case secondary
    }

    struct Model: Equatable {
        var title: String
        var style: Style
        var isEnabled: Bool
    }

    private let button = UIButton(type: .system)

    init(model: Model) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        layer.cornerRadius = DS.Radius.m
        layer.masksToBounds = true
        button.titleLabel?.font = DS.Typography.bodyMedium
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: DS.Layout.buttonHeight)
        ])
        button.backgroundColor = .clear
        apply(model)
    }

    override var intrinsicContentSize: CGSize {
        var size = button.intrinsicContentSize
        size.height = DS.Layout.buttonHeight
        return size
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(_ model: Model) {
        button.setTitle(model.title, for: .normal)
        button.isEnabled = model.isEnabled
        applyStyle(style: model.style, isEnabled: model.isEnabled)
        invalidateIntrinsicContentSize()
    }

    func addTouchUpInside(_ target: Any?, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }

    private func applyStyle(style: Style, isEnabled: Bool) {
        switch style {
        case .primary:
            backgroundColor = isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.35)
            button.setTitleColor(DS.Colors.textOnPrimary, for: .normal)
            button.setTitleColor(DS.Colors.textOnPrimary.withAlphaComponent(0.7), for: .highlighted)
        case .secondary:
            backgroundColor = .clear
            button.setTitleColor(isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.35), for: .normal)
            button.setTitleColor(DS.Colors.primary.withAlphaComponent(0.6), for: .highlighted)
        }
    }
}
