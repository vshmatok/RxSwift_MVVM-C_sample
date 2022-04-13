//
//  LoginViewModel.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol LoginViewModel: AnyObject {

    // MARK: - Inputs

    var email: PublishSubject<String?> { get }
    var password: PublishSubject<String?> { get }
    var isEmailViewActive: PublishSubject<Bool> { get }
    var isPasswordViewActive: PublishSubject<Bool> { get }
    var authorizationTrigger: PublishSubject<Void> { get }
    var registrationTrigger: PublishSubject<Void> { get }

    // MARK: - Outputs

    var isAuthorizationEnabled: Driver<Bool> { get }
    var emailErrorMessage: Driver<String?> { get }
    var passwordErrorMessage: Driver<String?> { get }
    var authorizationErrorMessage: Driver<String?> { get }
    var isLoading: Driver<Bool> { get }
}

final class LoginViewModelImpl: LoginViewModel {

    // MARK: - Properties

    private weak var coordinator: AuthorizationCoordinator?
    private var emailValidator: BaseValidator
    private var passwordValidator: BaseValidator
    private var authorizationService: AuthorizationService
    private var userService: UserService

    private let disposeBag = DisposeBag()

    // MARK: - Inputs

    var email = PublishSubject<String?>()
    var password = PublishSubject<String?>()
    var authorizationTrigger = PublishSubject<Void>()
    var registrationTrigger = PublishSubject<Void>()
    var isEmailViewActive = PublishSubject<Bool>()
    var isPasswordViewActive = PublishSubject<Bool>()

    // MARK: - Outputs

    private var isAuthorizationEnabledSubject = BehaviorRelay<Bool>(value: false)
    var isAuthorizationEnabled: Driver<Bool> { return isAuthorizationEnabledSubject.asDriver() }

    private var emailErrorSubject = BehaviorRelay<String?>(value: nil)
    var emailErrorMessage: Driver<String?> { return emailErrorSubject.asDriver() }

    private var passwordErrorSubject = BehaviorRelay<String?>(value: nil)
    var passwordErrorMessage: Driver<String?> { return passwordErrorSubject.asDriver() }

    private var authorizationErrorSubject = PublishRelay<String?>()
    var authorizationErrorMessage: Driver<String?> { return authorizationErrorSubject.asDriver(onErrorJustReturn: nil) }

    private var isLoadingSubject = BehaviorRelay<Bool>(value: false)
    var isLoading: Driver<Bool> { return isLoadingSubject.asDriver(onErrorJustReturn: false) }

    // MARK: - Initialization

    init(coordinator: AuthorizationCoordinator,
         emailValidator: BaseValidator = EmailValidatorImpl(),
         passwordValidator: BaseValidator = PasswordValidatorImpl(),
         authorizationService: AuthorizationService = AuthorizationServiceImpl(),
         userService: UserService = UserServiceImpl.instance) {
        self.coordinator = coordinator
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.authorizationService = authorizationService
        self.userService = userService

        prepareSubjects()
    }

    // MARK: - Private

    private func prepareSubjects() {
        let isEmailTextFieldActive = isEmailViewActive.asObservable().share(replay: 1)

        isEmailTextFieldActive
            .filter({ !$0 })
            .withLatestFrom(email.asObservable())
            .map { [weak self] email -> String? in
                let emailValidation = self?.emailValidator.validate(email)
                return emailValidation?.errorMessage
            }
            .bind(to: emailErrorSubject)
            .disposed(by: disposeBag)

        isEmailTextFieldActive
            .filter({ $0 })
            .map({ _ in nil })
            .bind(to: emailErrorSubject)
            .disposed(by: disposeBag)

        let isPasswordTextFieldActive = isPasswordViewActive.asObservable().share(replay: 1)

        isPasswordTextFieldActive
            .filter({ !$0 })
            .withLatestFrom(password.asObservable())
            .map { [weak self] password -> String? in
                let passwordValidation = self?.passwordValidator.validate(password)
                return passwordValidation?.errorMessage
            }
            .bind(to: passwordErrorSubject)
            .disposed(by: disposeBag)

        isPasswordTextFieldActive
            .filter({ $0 })
            .map({ _ in nil })
            .bind(to: passwordErrorSubject)
            .disposed(by: disposeBag)

        registrationTrigger
            .withLatestFrom(email.asObservable())
            .subscribe(onNext: { [weak self] email in
                self?.coordinator?.openRegistrationModule(email: email)
            })
            .disposed(by: disposeBag)

        authorizationTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.isLoadingSubject.accept(true)
            })
            .disposed(by: disposeBag)

        var credentials: Observable<(String?, String?)> {
            return Observable.combineLatest(email.asObservable(), password.asObservable()) { email, password in
                return (email, password)
            }
        }

        authorizationTrigger
            .withLatestFrom(credentials)
            .flatMapLatest { [weak self] (email, password) -> Observable<Event<User>> in
                guard let self = self, let email = email, let password = password else { return .never() }
                return self.authorizationService.authorize(email: email, password: password)
                    .materialize()
                    .delay(.seconds(2), scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: { [weak self] event in
                self?.isLoadingSubject.accept(false)
                switch event {
                case .next(let user):
                    self?.userService.save(user: user)
                case .error(let error):
                    self?.authorizationErrorSubject.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let isValidCredentials = credentials
            .map({ [weak self] (email, password) -> Bool in
                guard let self = self else { return true }

                let emailValidation = self.emailValidator.validate(email)
                let passwordValidation = self.passwordValidator.validate(password)

                return emailValidation.isValid && passwordValidation.isValid
            })

        Observable.combineLatest(isValidCredentials,
                                 isEmailTextFieldActive,
                                 isPasswordTextFieldActive,
                                 isLoadingSubject.asObservable()) { isValidCredentials, isEmailTextFieldActive, isPasswordTextFieldActive, isLoading in
            return isValidCredentials && !isEmailTextFieldActive && !isPasswordTextFieldActive && !isLoading
        }
                                 .distinctUntilChanged()
                                 .bind(to: isAuthorizationEnabledSubject)
                                 .disposed(by: disposeBag)

    }
}
