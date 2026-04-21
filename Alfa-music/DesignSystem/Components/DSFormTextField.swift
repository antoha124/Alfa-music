import UIKit

final class DSFormTextField: UIView {

    struct Model {
        var title: String
        var placeholder: String
        var errorMessage: String?
        var isSecure: Bool
        var keyboardType: UIKeyboardType
        var autocapitalizationType: UITextAutocapitalizationType
        var returnKeyType: UIReturnKeyType
    }

    private var titleLabel = UILabel()
    private var textField = UITextField()
    private var errorLabel = UILabel()

    var onEditingChanged: (() -> Void)?

    var onReturn: (() -> Bool)?

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
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)

        errorLabel.ds_apply(.errorField)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        var stack = UIStackView(arrangedSubviews: [titleLabel, textField, errorLabel])
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

    func render(_ model: Model) {
        titleLabel.text = model.title
        textField.attributedPlaceholder = NSAttributedString(
            string: model.placeholder,
            attributes: [
                .foregroundColor: DS.Colors.textSecondary,
                .font: DS.Typography.body
            ]
        )
        textField.isSecureTextEntry = model.isSecure
        textField.keyboardType = model.keyboardType
        textField.autocapitalizationType = model.autocapitalizationType
        textField.returnKeyType = model.returnKeyType

        errorLabel.text = model.errorMessage
        var hasError = !(model.errorMessage == nil || model.errorMessage?.isEmpty == true)
        errorLabel.isHidden = !hasError
        textField.layer.borderWidth = hasError ? 1 : 0
        textField.layer.borderColor = hasError ? DS.Colors.error.cgColor : nil
    }

    func currentText() -> String {
        textField.text ?? ""
    }

    func setText(_ text: String?) {
        textField.text = text
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    @objc private func editingChanged() {
        onEditingChanged?()
    }
}

extension DSFormTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?() ?? true
    }
}

extension DSFormTextField.Model {
    static func email(errorMessage: String?) -> DSFormTextField.Model {
        DSFormTextField.Model(
            title: "Email",
            placeholder: "Email",
            errorMessage: errorMessage,
            isSecure: false,
            keyboardType: .emailAddress,
            autocapitalizationType: .none,
            returnKeyType: .next
        )
    }

    static func password(errorMessage: String?) -> DSFormTextField.Model {
        DSFormTextField.Model(
            title: "Пароль",
            placeholder: "Пароль",
            errorMessage: errorMessage,
            isSecure: true,
            keyboardType: .default,
            autocapitalizationType: .none,
            returnKeyType: .done
        )
    }
}
