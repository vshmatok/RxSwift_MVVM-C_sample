//
//  NameValidator.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation

enum NameValidatorError: LocalizedError {

    // MARK: - Cases

    case emptyName
    case notValidName

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Name can't be empty or contain only whitespaces and newlines"
        case .notValidName:
            return "Name is not valid"
        }
    }
}

struct NameValidatorImpl: BaseValidator {
    func validate(_ object: String?) -> ValidationResult {
        guard let trimmedString = object?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return .error(NameValidatorError.emptyName)
        }

        guard trimmedString.count > 2 else { return .error(NameValidatorError.notValidName)}

        return .success
    }
}
