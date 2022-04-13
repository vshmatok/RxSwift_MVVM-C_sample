//
//  SceneDelegate.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var window: UIWindow?

    private var applicationCoordinator: ApplicationCoordinator?

    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        prepareWindow(scene: scene)
        initializeFlow()
    }

    // MARK: - Private

    private func prepareWindow(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
    }

    private func initializeFlow() {
        applicationCoordinator = ApplicationCoordinatorImpl(window: window)
        applicationCoordinator?.start()
    }
}

