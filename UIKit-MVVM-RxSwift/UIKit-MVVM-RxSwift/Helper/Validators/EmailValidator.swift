//
//  EmailValidator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 28.03.2022.
//

import Foundation

enum EmailValidatorError: LocalizedError {

    // MARK: - Cases

    case emptyEmail
    case notValidEmail

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email can't be empty or contain only whitespaces and newlines"
        case .notValidEmail:
            return "Email is not valid"
        }
    }
}

struct EmailValidatorImpl: BaseValidator {
    func validate(_ object: String?) -> ValidationResult {
        guard let trimmedString = object?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return .error(EmailValidatorError.emptyEmail)
        }

        let emailRegex = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")

        guard emailRegex.evaluate(with: trimmedString) else {
            return .error(EmailValidatorError.notValidEmail)
        }

        return .success
    }
}
