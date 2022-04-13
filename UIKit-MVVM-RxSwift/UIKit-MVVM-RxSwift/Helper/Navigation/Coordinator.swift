//
//  Coordinator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var parentCoordinator: Coordinator? { get set }

    func start()
}
