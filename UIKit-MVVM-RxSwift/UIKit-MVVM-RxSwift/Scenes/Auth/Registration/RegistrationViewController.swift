//
//  RegistrationViewController.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import RxSwift
import RxCocoa
import UIKit

// MARK: - Protocols

protocol RegistrationView: Presentable {
    var viewModel: RegistrationViewModel! { get set }
}

final class RegistrationViewController: UIViewController, RegistrationView {

    // MARK: - Constants

    private struct Constants {
        static let navigationBarTitle = "Registration"
        static let registrationButtonText = "Register"
    }

    // MARK: - Views

    private lazy var tableView: SelfSizedTableView = {
        let tableView = SelfSizedTableView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

        return tableView
    }()

    private lazy var registerButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.setTitle(Constants.registrationButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

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

    var viewModel: RegistrationViewModel!

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

        tableView.register(RegistrationInputTableViewCell.self,
                           forCellReuseIdentifier: RegistrationInputTableViewCell.className)
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(registerButton)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),

            registerButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            registerButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            registerButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            registerButton.heightAnchor.constraint(equalToConstant: 40),

            activityIndicator.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor)
            ])
    }

    private func bindUI() {
        viewModel.isRegistrationEnabled.drive(onNext: { [weak self] isEnabled in
            self?.registerButton.isEnabled = isEnabled

            UIView.animate(withDuration: 0.3) {
                self?.registerButton.alpha = isEnabled ? 1 : 0.5
            }
        }).disposed(by: disposeBag)

        viewModel.registrationErrorMessage.drive(onNext: { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)

        viewModel.isLoading.drive(onNext: { [weak self] isLoading in
            self?.registerButton.isHidden = isLoading
            self?.tableView.isUserInteractionEnabled = !isLoading
            self?.activityIndicator.isHidden = !isLoading
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }).disposed(by: disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        viewModel.dataSource.drive(tableView.rx.items(cellIdentifier: RegistrationInputTableViewCell.className,
                                                      cellType: UITableViewCell.self)) { row, element, cell in
            if let view = cell as? RegistrationCellView {
                view.configure(with: element)
            }
        }
        .disposed(by: disposeBag)

        registerButton.rx.tap.bind(to: viewModel.registrationTrigger).disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension RegistrationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct RegistrationViewControllerPreview: PreviewProvider {

    static var previews: some View {
        RegistrationViewController().toPreview()
    }
}
#endif
