//
//  NSObject+ClassName.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return String(describing: type(of: self))
    }
}
