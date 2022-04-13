//
//  MainViewController.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol MainView: Presentable {
    var viewModel: MainViewModel! { get set }
}

final class MainViewController: UIViewController, MainView {

    // MARK: - Constants

    private struct Constants {
        static let navigationBarTitle = "Profile"
        static let nameLabelPrefix: String = "Name: "
        static let logoutButtonText: String = "Logout"
    }

    // MARK: - Views

    private var mainContainerStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center

        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()

        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.setTitle(Constants.logoutButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)

        return button
    }()

    // MARK: - Properties

    var viewModel: MainViewModel!

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
        view.addSubview(mainContainerStackView)

        mainContainerStackView.addArrangedSubview(nameLabel)
        mainContainerStackView.addArrangedSubview(logoutButton)

        NSLayoutConstraint.activate([
            mainContainerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainContainerStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            mainContainerStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),

            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func bindUI() {
        logoutButton.rx.tap.bind(to: viewModel.logoutTrigger).disposed(by: disposeBag)

        viewModel.name
            .drive(onNext: { [weak self] name in
                self?.nameLabel.text = "\(Constants.nameLabelPrefix)\(name ?? "Unknown")"
            })
            .disposed(by: disposeBag)
    }

}

// MARK: - Preview

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct MainViewControllerPreview: PreviewProvider {

    static var previews: some View {
        MainViewController().toPreview()
    }
}
#endif
