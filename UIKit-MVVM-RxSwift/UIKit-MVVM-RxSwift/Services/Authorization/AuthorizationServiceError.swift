//
//  AuthorizationServiceError.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation

enum AuthorizationServiceError: LocalizedError {

    // MARK: - Cases

    case wrongCredentials
    case emailIsTaken

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .wrongCredentials:
            return "Unfortunately user isn't found"
        case .emailIsTaken:
            return "Email is taken. Please change email or enter account"
        }
    }
}
