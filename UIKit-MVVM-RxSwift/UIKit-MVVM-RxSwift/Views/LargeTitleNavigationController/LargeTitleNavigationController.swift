//
//  AuthorizationNavigationController.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 28.03.2022.
//

import UIKit

final class LargeTitleNavigationController: UINavigationController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
    }
}
