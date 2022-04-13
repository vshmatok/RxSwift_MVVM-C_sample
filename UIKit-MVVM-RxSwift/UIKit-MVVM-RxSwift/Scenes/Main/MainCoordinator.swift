//
//  MainCoordinator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 28.03.2022.
//

import UIKit

protocol MainCoordinator: Coordinator { }

final class MainCoordinatorImpl: BaseCoordinator {

    // MARK: - Properties

    private var router: Routable

    // MARK: - Initialization

    init(router: Routable) {
        self.router = router
    }
}

// MARK: - MainCoordinator

extension MainCoordinatorImpl: MainCoordinator {
    func start() {
        var mainModule: MainView = MainViewController()
        let viewModel: MainViewModel = MainViewModelImpl(coordinator: self)

        mainModule.viewModel = viewModel

        router.setRootModule(mainModule)
    }
}
