//
//  ApplicationCoordinator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 28.03.2022.
//

import UIKit
import RxSwift

protocol ApplicationCoordinator: Coordinator {}

final class ApplicationCoordinatorImpl: BaseCoordinator {

    // MARK: - Properties

    private weak var window: UIWindow?
    private var userService: UserService

    private var disposeBag = DisposeBag()

    // MARK: - Initialization

    init(window: UIWindow?,
         userService: UserService = UserServiceImpl.instance) {
        self.window = window
        self.userService = userService
    }

    // MARK: - Private

    private func prepareAuthFlow() -> UIViewController? {
        let navigationController = LargeTitleNavigationController()
        let router: Routable = Router(navigationController: navigationController)
        let authCoordinator: AuthorizationCoordinator = AuthorizationCoordinatorImpl(router: router)

        authCoordinator.parentCoordinator = self
        addDependency(authCoordinator)
        authCoordinator.start()

        return router.toPresent
    }

    private func prepareMainFlow() -> UIViewController? {
        let navigationController = LargeTitleNavigationController()
        let router: Routable = Router(navigationController: navigationController)
        let mainCoordinator: MainCoordinator = MainCoordinatorImpl(router: router)

        mainCoordinator.parentCoordinator = self
        addDependency(mainCoordinator)
        mainCoordinator.start()

        return router.toPresent
    }
}

// MARK: - ApplicationCoordinator

extension ApplicationCoordinatorImpl: ApplicationCoordinator {
    func start() {
        userService.activeUser
            .subscribe(onNext: { [weak self] user in
                self?.childCoordinators.removeAll()

                let rootModule = user != nil ? self?.prepareMainFlow() : self?.prepareAuthFlow()

                self?.window?.rootViewController = rootModule
                self?.window?.makeKeyAndVisible()
            })
            .disposed(by: disposeBag)
    }
}
