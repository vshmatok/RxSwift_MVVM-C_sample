//
//  UserService.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation
import RxSwift
import RxRelay

// MARK: - Protocols

protocol UserService: AnyObject {
    var activeUser: Observable<User?> { get }

    func save(user: User)
    func removeActiveUser()
}

final class UserServiceImpl: UserService {

    // MARK: - Constants

    private struct Constants {
        static let userKey: String = "savedUser"
    }

    // MARK: - Properties

    static let instance: UserService = UserServiceImpl()

    private var userDefaults: UserDefaults

    private var userSubject = BehaviorRelay<User?>(value: nil)
    var activeUser: Observable<User?> { return userSubject.asObservable().share(replay: 1) }

    // MARK: - Initialization

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        setActiveUser()
    }

    // MARK: - UserService

    func save(user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            userDefaults.set(encoded, forKey: Constants.userKey)
            userSubject.accept(user)
        }
    }

    func removeActiveUser() {
        userDefaults.removeObject(forKey: Constants.userKey)
        userSubject.accept(nil)
    }

    // MARK: - Private

    private func setActiveUser() {
        guard let savedUser = userDefaults.object(forKey: Constants.userKey) as? Data,
              let user = try? JSONDecoder().decode(User.self, from: savedUser) else {
                  return
              }

        userSubject.accept(user)
    }
}
