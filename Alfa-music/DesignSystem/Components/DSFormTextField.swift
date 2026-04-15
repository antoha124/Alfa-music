import UIKit

final class DSFormTextField: UIView {

    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let errorLabel = UILabel()

    var input: UITextField { textField }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.ds_apply(.caption)
        titleLabel.numberOfLines = 1

        textField.ds_applyInputTypography()
        textField.borderStyle = .none
        textField.backgroundColor = DS.Colors.elevated
        textField.layer.cornerRadius = DS.Radius.m
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: DS.Spacing.m, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: DS.Spacing.m, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.ds_apply(.errorField)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, textField, errorLabel])
        stack.axis = .vertical
        stack.spacing = DS.Layout.FormField.labelToInputSpacing
        stack.setCustomSpacing(DS.Layout.FormField.inputToErrorSpacing, after: textField)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: DS.Layout.textFieldHeight)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        placeholder: String,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .sentences,
        returnKeyType: UIReturnKeyType = .default
    ) {
        titleLabel.text = title
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: DS.Colors.textSecondary,
                .font: DS.Typography.body()
            ]
        )
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalizationType
        textField.returnKeyType = returnKeyType
    }

    func setErrorText(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil || message?.isEmpty == true
        let hasError = !(message == nil || message?.isEmpty == true)
        textField.layer.borderWidth = hasError ? 1 : 0
        textField.layer.borderColor = hasError ? DS.Colors.error.cgColor : nil
    }
}
