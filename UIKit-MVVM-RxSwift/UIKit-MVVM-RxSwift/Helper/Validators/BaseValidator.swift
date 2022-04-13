//
//  BaseValidator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 29.03.2022.
//

import Foundation

enum ValidationResult {

    // MARK: - Cases

    case success
    case error(LocalizedError)

    // MARK: - Properties

    var isValid: Bool {
        switch self {
        case .error:
            return false
        case .success:
            return true
        }
    }

    var errorMessage: String? {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .success:
            return nil
        }
    }
}

protocol BaseValidator {
    func validate(_ object: String?) -> ValidationResult
}
