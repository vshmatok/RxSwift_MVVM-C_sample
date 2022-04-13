//
//  Presentable.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import UIKit

protocol Presentable {
    var toPresent: UIViewController? { get }
}

// MARK: - Presentable

extension UIViewController: Presentable {
    var toPresent: UIViewController? {
        return self
    }
}
