//
//  FinishedRegistrationViewModel.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol FinishedRegistrationViewModel: AnyObject {

    // MARK: - Inputs

    var backButtonTrigger: PublishSubject<Void> { get }

    // MARK: - Output

    var title: Driver<String?> { get }
}

final class FinishedRegistrationViewModelImpl: FinishedRegistrationViewModel {

    // MARK: - Properties

    private weak var coordinator: AuthorizationCoordinator?

    private let disposeBag = DisposeBag()

    // MARK: - Inputs

    var backButtonTrigger = PublishSubject<Void>()

    // MARK: - Output

    private var titleSubject = BehaviorRelay<(String?, String?)>(value: (nil, nil))
    var title: Driver<String?> {
        return titleSubject.asDriver(onErrorJustReturn: (nil, nil))
            .map({ (email, name) in
                return "Thanks \(name ?? "").\nTo finish registration go to \(email ?? "")"
            })
    }

    // MARK: - Initialization

    init(input: FinishRegistrationModuleInput,
         coordinator: AuthorizationCoordinator?) {
        self.coordinator = coordinator

        titleSubject.accept((input.email, input.name))

        prepareSubjects()
    }

    // MARK: - Private

    private func prepareSubjects() {
        backButtonTrigger
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.navigateToRoot()
            })
            .disposed(by: disposeBag)
    }

}
