//
//  AuthorizationService.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation
import RxSwift

// MARK: - Protocols

protocol AuthorizationService: AnyObject {
    func authorize(email: String, password: String) -> Observable<User>
    func register(email: String, name: String, password: String) -> Observable<(String, String)>
}

final class AuthorizationServiceImpl: AuthorizationService {

    // MARK: - Constants

    private struct Constants {
        static let predefinedEmail: String = "test@mail.com"
        static let predefinedPassword: String = "123456"

        static let predefinedUser: User = User(name: "Test")
    }

    // MARK: - AuthorizationService

    func authorize(email: String, password: String) -> Observable<User> {
        return Observable.create { observable in
            guard email == Constants.predefinedEmail, password == Constants.predefinedPassword else
            {
                observable.on(.error(AuthorizationServiceError.wrongCredentials))
                return Disposables.create()
            }

            observable.on(.next(Constants.predefinedUser))
            observable.on(.completed)


            return Disposables.create()
        }
    }

    func register(email: String, name: String, password: String) -> Observable<(String, String)> {
        return Observable.create { observable in
            if email == Constants.predefinedEmail {
                observable.on(.error(AuthorizationServiceError.emailIsTaken))
                return Disposables.create()
            }

            observable.on(.next((email, name)))
            observable.on(.completed)

            return Disposables.create()
        }
    }

}
