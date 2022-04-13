//
//  PasswordValidator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 29.03.2022.
//

import Foundation

enum PasswordValidatorError: LocalizedError {

    // MARK: - Cases

    case emptyPassword
    case notValidPassword

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .emptyPassword:
            return "Password can't be empty or contain only whitespaces and newlines"
        case .notValidPassword:
            return "Password is not valid"
        }
    }
}

struct PasswordValidatorImpl: BaseValidator {
    func validate(_ object: String?) -> ValidationResult {
        guard let trimmedString = object?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return .error(PasswordValidatorError.emptyPassword)
        }

        guard trimmedString.count > 1 && trimmedString.count < 16 else {
            return .error(PasswordValidatorError.notValidPassword)
        }

        return .success
    }
}
