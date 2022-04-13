//
//  AuthorizationCoordinator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 28.03.2022.
//

import UIKit

protocol AuthorizationCoordinator: Coordinator {
    func openRegistrationModule(email: String?)
    func openRegistrationFinish(email: String?, name: String?)
    func navigateToRoot()
}

final class AuthorizationCoordinatorImpl: BaseCoordinator {

    // MARK: - Properties

    private var router: Routable

    // MARK: - Initialization

    init(router: Routable) {
        self.router = router
    }
}

// MARK: - MainCoordinator

extension AuthorizationCoordinatorImpl: AuthorizationCoordinator {
    func start() {
        var loginModule: LoginView = LoginViewController()
        let viewModel: LoginViewModel = LoginViewModelImpl(coordinator: self)

        loginModule.viewModel = viewModel

        router.setRootModule(loginModule)
    }

    func openRegistrationModule(email: String?) {
        let input = RegistrationModuleInput(email: email)

        let viewModel: RegistrationViewModel = RegistrationViewModelImpl(input: input, coordinator: self)

        var registrationModule: RegistrationView = RegistrationViewController()
        registrationModule.viewModel = viewModel

        router.push(registrationModule, animated: true)
    }

    func openRegistrationFinish(email: String?, name: String?) {
        let input = FinishRegistrationModuleInput(email: email, name: name)

        let viewModel: FinishedRegistrationViewModel = FinishedRegistrationViewModelImpl(input: input, coordinator: self)

        var finishRegistrationModule: FinishedRegistrationView = FinishedRegistrationViewController()
        finishRegistrationModule.viewModel = viewModel

        router.push(finishRegistrationModule, animated: true)
    }

    func navigateToRoot() {
        router.popToRootModule(animated: true)
    }
}
