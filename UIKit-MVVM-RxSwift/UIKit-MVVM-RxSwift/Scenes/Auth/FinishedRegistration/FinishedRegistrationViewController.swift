//
//  FinishedRegistrationViewController.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol FinishedRegistrationView: Presentable {
    var viewModel: FinishedRegistrationViewModel! { get set }
}

final class FinishedRegistrationViewController: UIViewController, FinishedRegistrationView {

    // MARK: - Constants

    private struct Constants {
        static let backButton: String = "Back"
    }

    // MARK: - Views

    private var mainContainerStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.setTitle(Constants.backButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        return button
    }()

    // MARK: - Properties

    var viewModel: FinishedRegistrationViewModel!

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        prepareUI()
        bindUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Private

    private func prepareUI() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupLayout() {
        view.addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(titleLabel)
        mainContainerStackView.addArrangedSubview(backButton)

        NSLayoutConstraint.activate([
            mainContainerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainContainerStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            mainContainerStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),

            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func bindUI() {
        backButton.rx.tap.bind(to: viewModel.backButtonTrigger).disposed(by: disposeBag)

        viewModel.title
            .drive(onNext: { [weak self] title in
                self?.titleLabel.text = title
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Preview

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct FinishedRegistrationViewControllerPreview: PreviewProvider {

    static var previews: some View {
        FinishedRegistrationViewController().toPreview()
    }
}
#endif
