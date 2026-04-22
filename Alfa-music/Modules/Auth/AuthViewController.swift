import UIKit

class AuthViewController: UIViewController, AuthView {

    var viewModel: AuthViewModelProtocol?

    private var scrollView = UIScrollView()

    private var logoLabel: UILabel = {
        var label = UILabel()
        label.text = "Alfa Music"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var emailField = DSFormTextField(model: DSFormTextField.Model.email(errorMessage: nil))
    private var passwordField = DSFormTextField(model: DSFormTextField.Model.password(errorMessage: nil))

    private var errorLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var loginButton = DSButton(
        model: DSButton.Model(title: "Войти", style: .primary, isEnabled: true)
    )
    private var guestButton = DSButton(
        model: DSButton.Model(title: "Войти как гость", style: .secondary, isEnabled: true)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.background

        logoLabel.ds_apply(.titleLarge)

        emailField.onReturn = { [weak self] in
            _ = self?.passwordField.becomeFirstResponder()
            return false
        }
        passwordField.onReturn = { [weak self] in
            self?.loginTapped()
            return true
        }

        errorLabel.ds_apply(.errorBanner)

        setupLayout()
        setupKeyboardObserver()

        loginButton.addTouchUpInside(self, action: #selector(loginTapped))
        guestButton.addTouchUpInside(self, action: #selector(guestTapped))

        viewModel?.view = self
        viewModel?.didLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        var contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        var formStack = UIStackView(arrangedSubviews: [
            emailField,
            passwordField,
            errorLabel,
            loginButton,
            guestButton
        ])
        formStack.axis = .vertical
        formStack.alignment = .center
        formStack.spacing = DS.Spacing.m
        formStack.setCustomSpacing(DS.Layout.Auth.fieldsToErrorSpacing, after: passwordField)
        formStack.setCustomSpacing(DS.Layout.Auth.fieldsToButtonSpacing, after: passwordField)
        formStack.translatesAutoresizingMaskIntoConstraints = false

        var stack = UIStackView(arrangedSubviews: [logoLabel, formStack])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DS.Layout.Auth.titleToFieldsSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        var dynamicFieldWidthConstraint = emailField.widthAnchor.constraint(
            equalTo: contentView.widthAnchor,
            constant: -DS.Layout.Auth.horizontalInset * 2
        )
        dynamicFieldWidthConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            dynamicFieldWidthConstraint,
            passwordField.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            errorLabel.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            loginButton.widthAnchor.constraint(equalTo: emailField.widthAnchor),
            guestButton.widthAnchor.constraint(equalTo: emailField.widthAnchor)
        ])
    }

    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ note: Notification) {
        guard
            var userInfo = note.userInfo,
            var endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        var keyboardInView = view.convert(endFrame, from: nil)
        var intersection = view.bounds.intersection(keyboardInView)
        scrollView.contentInset.bottom = intersection.height
        scrollView.verticalScrollIndicatorInsets.bottom = intersection.height
    }

    @objc private func loginTapped() {
        viewModel?.didTapLogin(
            email: emailField.currentText(),
            password: passwordField.currentText()
        )
    }

    @objc private func guestTapped() {
        viewModel?.didTapGuestLogin()
    }

    func render(_ state: AuthViewState) {
        if var error = state.errorText {
            errorLabel.text = error
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
}
