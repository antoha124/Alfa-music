import UIKit

final class DSStateContainerView: UIView {

    enum State: Equatable {
        case hidden
        case loading(message: String?)
        case empty(title: String, message: String)
        case error(message: String, showsRetry: Bool)
    }

    var onRetry: (() -> Void)?

    private var stack = UIStackView()
    private var activity = UIActivityIndicatorView(style: .large)
    private var iconView = UIImageView()
    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    private var retryButton = DSButton(style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DS.Spacing.m
        stack.translatesAutoresizingMaskIntoConstraints = false

        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = DS.Colors.textSecondary
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isHidden = true

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.ds_apply(.titleScreen)

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.ds_apply(.body)

        retryButton.setTitle("Повторить", for: .normal)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.isHidden = true

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DS.Spacing.l),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DS.Spacing.l),
            iconView.widthAnchor.constraint(equalToConstant: DSIcon.Size.l.rawValue),
            iconView.heightAnchor.constraint(equalToConstant: DSIcon.Size.l.rawValue)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setState(_ state: State) {
        activity.stopAnimating()
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch state {
        case .hidden:
            isHidden = true

        case .loading(let message):
            isHidden = false
            iconView.isHidden = true
            titleLabel.isHidden = true
            retryButton.isHidden = true
            stack.addArrangedSubview(activity)
            activity.startAnimating()
            if let message, !message.isEmpty {
                var label = UILabel()
                label.text = message
                label.textAlignment = .center
                label.ds_apply(.captionSecondary)
                stack.addArrangedSubview(label)
            }

        case .empty(let title, let message):
            isHidden = false
            iconView.isHidden = true
            titleLabel.isHidden = true
            retryButton.isHidden = true
            if var img = DSIcon.template(DSIcon.Name.tray, size: .l) {
                iconView.image = img
                iconView.tintColor = DS.Colors.textSecondary
                iconView.isHidden = false
                stack.addArrangedSubview(iconView)
            }
            titleLabel.text = title
            titleLabel.isHidden = false
            stack.addArrangedSubview(titleLabel)
            messageLabel.ds_apply(.body)
            messageLabel.text = message
            stack.addArrangedSubview(messageLabel)

        case .error(let message, let showsRetry):
            isHidden = false
            iconView.isHidden = true
            titleLabel.isHidden = true
            if var img = DSIcon.template(DSIcon.Name.exclamationTriangle, size: .l) {
                iconView.image = img
                iconView.tintColor = DS.Colors.error
                iconView.isHidden = false
                stack.addArrangedSubview(iconView)
            }
            messageLabel.text = message
            messageLabel.ds_apply(.errorBanner)
            stack.addArrangedSubview(messageLabel)
            if showsRetry {
                retryButton.isHidden = false
                stack.addArrangedSubview(retryButton)
            } else {
                retryButton.isHidden = true
            }
        }
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
