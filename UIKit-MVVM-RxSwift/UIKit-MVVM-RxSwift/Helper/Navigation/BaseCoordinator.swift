//
//  BaseCoordinator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import Foundation

class BaseCoordinator {

    // MARK: - Properties

    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    // MARK: - Public

    func addDependency(_ coordinator: Coordinator) {
        guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
        childCoordinators.append(coordinator)
    }

    func removeDependency(_ coordinator: Coordinator?) {
        guard !childCoordinators.isEmpty else { return }
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
