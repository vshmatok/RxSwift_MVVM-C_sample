//
//  LoginViewController.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol LoginView: Presentable {
    var viewModel: LoginViewModel! { get set }
}

final class LoginViewController: UIViewController, LoginView {

    // MARK: - Constants

    private struct Constants {
        static let navigationBarTitle = "Authorization"
        static let emailLabelText: String = "Email"
        static let passwordLabelText: String = "Password"
        static let loginButtonText: String = "Login"
        static let registerButtonText: String = "Register"
    }

    // MARK: - Views

    private lazy var mainContainerView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private var inputStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        return stackView
    }()

    private lazy var emailContainerView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.emailLabelText
        label.font = UIFont.boldSystemFont(ofSize: 12)

        return label
    }()

    private lazy var emailTextField: UITextField = {
        let textField = UITextField()

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your email address...",
                                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        textField.textColor = .gray
        textField.returnKeyType = .next
        textField.keyboardType = .emailAddress

        return textField
    }()

    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 10)

        return label
    }()

    private lazy var passwordContainerView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var passwordLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.passwordLabelText
        label.font = UIFont.boldSystemFont(ofSize: 12)

        return label
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "Enter your password...",
                                                             attributes: [.font: UIFont.systemFont(ofSize: 14)])
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        textField.textColor = .gray
        textField.returnKeyType = .go

        return textField
    }()

    private lazy var passwordErrorLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 10)

        return label
    }()

    private lazy var actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        return stackView
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.setTitle(Constants.loginButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        return button
    }()

    private lazy var registerButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.registerButtonText, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)

        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray

        return activityIndicator
    }()

    // MARK: - Properties

    var viewModel: LoginViewModel!

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        prepareUI()
        bindUI()
    }

    // MARK: - Private

    private func prepareUI() {
        title = Constants.navigationBarTitle
        view.backgroundColor = .white
    }

    private func setupLayout() {
        view.addSubview(mainContainerView)

        mainContainerView.addSubview(inputStackView)

        inputStackView.addArrangedSubview(emailContainerView)
        inputStackView.addArrangedSubview(passwordContainerView)

        emailContainerView.addSubview(emailLabel)
        emailContainerView.addSubview(emailTextField)
        emailContainerView.addSubview(emailErrorLabel)

        passwordContainerView.addSubview(passwordLabel)
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(passwordErrorLabel)

        mainContainerView.addSubview(actionButtonsStackView)

        actionButtonsStackView.addArrangedSubview(loginButton)
        actionButtonsStackView.addArrangedSubview(registerButton)

        mainContainerView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            mainContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            mainContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),

            inputStackView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            inputStackView.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor),
            inputStackView.rightAnchor.constraint(equalTo: mainContainerView.rightAnchor),

            emailLabel.topAnchor.constraint(equalTo: emailContainerView.topAnchor),
            emailLabel.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor),
            emailLabel.rightAnchor.constraint(equalTo: emailContainerView.rightAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -8),

            emailTextField.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor),
            emailTextField.rightAnchor.constraint(equalTo: emailContainerView.rightAnchor),
            emailTextField.bottomAnchor.constraint(equalTo: emailErrorLabel.topAnchor),

            emailErrorLabel.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor),
            emailErrorLabel.rightAnchor.constraint(equalTo: emailContainerView.rightAnchor),
            emailErrorLabel.bottomAnchor.constraint(equalTo: emailContainerView.bottomAnchor),

            passwordLabel.topAnchor.constraint(equalTo: passwordContainerView.topAnchor),
            passwordLabel.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor),
            passwordLabel.rightAnchor.constraint(equalTo: passwordContainerView.rightAnchor),
            passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -8),

            passwordTextField.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor),
            passwordTextField.rightAnchor.constraint(equalTo: passwordContainerView.rightAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordErrorLabel.topAnchor),

            passwordErrorLabel.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor),
            passwordErrorLabel.rightAnchor.constraint(equalTo: passwordContainerView.rightAnchor),
            passwordErrorLabel.bottomAnchor.constraint(equalTo: passwordContainerView.bottomAnchor),

            actionButtonsStackView.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: 24),
            actionButtonsStackView.leftAnchor.constraint(equalTo: mainContainerView.leftAnchor),
            actionButtonsStackView.rightAnchor.constraint(equalTo: mainContainerView.rightAnchor),
            actionButtonsStackView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: actionButtonsStackView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: actionButtonsStackView.centerYAnchor)
        ])
    }

    private func bindUI() {
        viewModel.isAuthorizationEnabled.drive(onNext: { [weak self] isEnabled in
            self?.loginButton.isEnabled = isEnabled

            UIView.animate(withDuration: 0.3) {
                self?.loginButton.alpha = isEnabled ? 1 : 0.5
            }
        }).disposed(by: disposeBag)

        viewModel.authorizationErrorMessage.drive(onNext: { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)

        viewModel.isLoading.drive(onNext: { [weak self] isLoading in
            self?.actionButtonsStackView.isHidden = isLoading
            self?.passwordTextField.isEnabled = !isLoading
            self?.emailTextField.isEnabled = !isLoading
            self?.activityIndicator.isHidden = !isLoading
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }).disposed(by: disposeBag)

        viewModel.passwordErrorMessage.drive(passwordErrorLabel.rx.text).disposed(by: disposeBag)
        viewModel.emailErrorMessage.drive(emailErrorLabel.rx.text).disposed(by: disposeBag)

        emailTextField.rx.text.bind(to: viewModel.email).disposed(by: disposeBag)
        passwordTextField.rx.text.bind(to: viewModel.password).disposed(by: disposeBag)
        loginButton.rx.tap.bind(to: viewModel.authorizationTrigger).disposed(by: disposeBag)
        registerButton.rx.tap.bind(to: viewModel.registrationTrigger).disposed(by: disposeBag)

        let emailTextFieldBeginEditingObservable = emailTextField.rx.controlEvent(.editingDidBegin).asObservable()
            .map({ _ in true })
        let emailTextFieldEndEditingObservable = emailTextField.rx.controlEvent(.editingDidEnd).asObservable()
            .map({ _ in false })
        Observable.merge(emailTextFieldBeginEditingObservable,
                         emailTextFieldEndEditingObservable).bind(to: viewModel.isEmailViewActive).disposed(by: disposeBag)

        let passwordTextFieldBeginEditingObservable = passwordTextField.rx.controlEvent(.editingDidBegin).asObservable()
            .map({ _ in true })
        let passwordTextFieldEndEditingObservable = passwordTextField.rx.controlEvent(.editingDidEnd).asObservable()
            .map({ _ in false })
        Observable.merge(passwordTextFieldBeginEditingObservable,
                         passwordTextFieldEndEditingObservable).bind(to: viewModel.isPasswordViewActive).disposed(by: disposeBag)
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct LoginViewControllerPreview: PreviewProvider {

    static var previews: some View {
        LoginViewController().toPreview()
    }
}
#endif
