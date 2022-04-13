//
//  MainViewModel.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol MainViewModel: AnyObject {

    // MARK: - Inputs

    var logoutTrigger: PublishSubject<Void> { get }

    // MARK: - Output

    var name: Driver<String?> { get }
}

final class MainViewModelImpl: MainViewModel {

    // MARK: - Properties

    private weak var coordinator: MainCoordinator?
    private var userService: UserService

    private let disposeBag = DisposeBag()

    // MARK: - Inputs

    var logoutTrigger = PublishSubject<Void>()

    // MARK: - Output

    var name: Driver<String?> {
        return self.userService.activeUser
            .map({ $0?.name })
            .asDriver(onErrorJustReturn: nil)
    }

    // MARK: - Initialization

    init(coordinator: MainCoordinator?,
         userService: UserService = UserServiceImpl.instance) {
        self.coordinator = coordinator
        self.userService = userService

        prepareSubjects()
    }

    // MARK: - Private

    private func prepareSubjects() {
        logoutTrigger
            .subscribe(onNext: { [weak self] in
                self?.userService.removeActiveUser()
            })
            .disposed(by: disposeBag)
    }

}
