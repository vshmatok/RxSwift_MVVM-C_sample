//
//  Router.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import UIKit

protocol Routable: AnyObject, Presentable {
    func present(_ module: Presentable?, animated: Bool)

    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)

    func popModule(animated: Bool)

    func dismissModule(animated: Bool)
    func dismissModule(animated: Bool, completion: (() -> Void)?)

    func setRootModule(_ module: Presentable?)

    func popToRootModule(animated: Bool)
}

final class Router: NSObject {

    // MARK: - Properties

    private weak var navigationController: UINavigationController?
    private var completions: [UIViewController : (() -> Void)?] = [:]

    // MARK: - Initialization

    init(navigationController: UINavigationController?) {
        super.init()
        self.navigationController = navigationController
        self.navigationController?.delegate = self
    }

    // MARK: - Private

    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion?()
        completions.removeValue(forKey: controller)
    }
}

// MARK: - Routable

extension Router: Routable {

    var toPresent: UIViewController? {
        return navigationController
    }

    func present(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent else { return }
        navigationController?.present(controller, animated: animated, completion: nil)
    }

    func push(_ module: Presentable?, animated: Bool) {
        push(module, animated: animated, completion: nil)
    }

    func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
        guard
            let controller = module?.toPresent,
            !(controller is UINavigationController) else {
            assertionFailure("⚠️Deprecated push UINavigationController.")
            return
        }

        if let completion = completion {
            completions[controller] = completion
        }

        navigationController?.pushViewController(controller, animated: animated)
    }

    func popModule(animated: Bool) {
        if let controller = navigationController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func dismissModule(animated: Bool) {
        dismissModule(animated: animated, completion: nil)
    }

    func dismissModule(animated: Bool, completion: (() -> Void)?) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }

    func setRootModule(_ module: Presentable?) {
        guard let controller = module?.toPresent else { return }
        navigationController?.setViewControllers([controller], animated: false)
    }

    func popToRootModule(animated: Bool) {
        if let controllers = navigationController?.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension Router: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard let poppingViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(poppingViewController) else {
            return
        }

        runCompletion(for: poppingViewController)
    }
}
