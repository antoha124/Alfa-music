import UIKit

class AuthViewController: UIViewController, AuthView {

    var viewModel: AuthViewModelProtocol?

    private let scrollView = UIScrollView()

    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "Alfa Music"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Пароль"
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Войти"
        config.cornerStyle = .medium
        return UIButton(configuration: config)
    }()

    private let guestButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Войти как гость"
        return UIButton(configuration: config)
    }()



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupKeyboardObserver()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        guestButton.addTarget(self, action: #selector(guestTapped), for: .touchUpInside)

        emailTextField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)

        viewModel?.view = self
        viewModel?.didLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }



    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [logoLabel, emailTextField, emailErrorLabel, passwordTextField, passwordErrorLabel, errorLabel, loginButton, guestButton])
        stack.axis = .vertical
        stack.spacing = 4
        stack.setCustomSpacing(48, after: logoLabel)
        stack.setCustomSpacing(12, after: emailErrorLabel)
        stack.setCustomSpacing(12, after: passwordErrorLabel)
        stack.setCustomSpacing(24, after: errorLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),

            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
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
            let userInfo = note.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardInView = view.convert(endFrame, from: nil)
        let intersection = view.bounds.intersection(keyboardInView)
        scrollView.contentInset.bottom = intersection.height
        scrollView.verticalScrollIndicatorInsets.bottom = intersection.height
    }



    @objc private func emailChanged() {
        let text = emailTextField.text ?? ""
        guard !text.isEmpty else {
            setEmailError(nil)
            return
        }
        if !text.contains("@") || !text.contains(".") {
            setEmailError("Введите корректный email")
        } else {
            setEmailError(nil)
        }
    }

    @objc private func passwordChanged() {
        let text = passwordTextField.text ?? ""
        guard !text.isEmpty else {
            setPasswordError(nil)
            return
        }
        if text.count < 4 {
            setPasswordError("Минимум 4 символа")
        } else {
            setPasswordError(nil)
        }
    }


    private func setEmailError(_ message: String?) {
        emailErrorLabel.text = message
        emailErrorLabel.isHidden = message == nil
        emailTextField.layer.borderWidth = message == nil ? 0 : 1
        emailTextField.layer.borderColor = UIColor.systemRed.cgColor
        emailTextField.layer.cornerRadius = 6
    }

    private func setPasswordError(_ message: String?) {
        passwordErrorLabel.text = message
        passwordErrorLabel.isHidden = message == nil
        passwordTextField.layer.borderWidth = message == nil ? 0 : 1
        passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
        passwordTextField.layer.cornerRadius = 6
    }


    @objc private func loginTapped() {
        viewModel?.didTapLogin(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }

    @objc private func guestTapped() {
        viewModel?.didTapGuestLogin()
    }


    func render(_ state: AuthViewState) {
        if let error = state.errorText {
            errorLabel.text = error
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
}


extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginTapped()
        }
        return true
    }
}
