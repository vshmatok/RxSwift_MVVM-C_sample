//
//  RegistrationViewModel.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 26.03.2022.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocols

protocol RegistrationViewModel: AnyObject {

    // MARK: - Input

    var registrationTrigger: PublishSubject<Void> { get }

    // MARK: - Output

    var dataSource: Driver<[RegistrationInputCellViewModel]> { get }
    var isRegistrationEnabled: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var registrationErrorMessage: Driver<String?> { get }
}

final class RegistrationViewModelImpl: RegistrationViewModel {

    // MARK: - Properties

    private weak var coordinator: AuthorizationCoordinator?
    private var emailValidator: BaseValidator
    private var passwordValidator: BaseValidator
    private var nameValidator: BaseValidator
    private var authorizationService: AuthorizationService
    private var cellFactory: RegistrationInputCellFactory

    private let disposeBag = DisposeBag()

    // MARK: - Input

    private var emailInputSubject = BehaviorRelay<String?>(value: nil)
    private var isEmailInputViewActive = PublishRelay<Bool>()
    private var emailErrorMessageSubject = BehaviorRelay<String?>(value: nil)

    private var passwordInputSubject = BehaviorRelay<String?>(value: nil)
    private var isPasswordInputViewActive = PublishRelay<Bool>()
    private var passwordErrorMessageSubject = BehaviorRelay<String?>(value: nil)

    private var repeatPasswordInputSubject = BehaviorRelay<String?>(value: nil)
    private var isRepeatPasswordInputViewActive = PublishRelay<Bool>()
    private var repeatPasswordErrorMessageSubject = BehaviorRelay<String?>(value: nil)
    private var externalRepeatPasswordErrorMessageSubject = BehaviorRelay<String?>(value: nil)

    private var nameInputSubject = BehaviorRelay<String?>(value: nil)
    private var isNameInputViewActive = PublishRelay<Bool>()
    private var nameErrorMessageSubject = BehaviorRelay<String?>(value: nil)

    var registrationTrigger = PublishSubject<Void>()

    // MARK: - Output

    private var dataSourceSubject = BehaviorRelay<[RegistrationInputCellViewModel]>(value: [])
    var dataSource: Driver<[RegistrationInputCellViewModel]> { return dataSourceSubject.asDriver() }

    private var isRegistrationEnabledSubject = BehaviorRelay<Bool>(value: false)
    var isRegistrationEnabled: Driver<Bool> { return isRegistrationEnabledSubject.asDriver() }

    private var isLoadingSubject = BehaviorRelay<Bool>(value: false)
    var isLoading: Driver<Bool> { return isLoadingSubject.asDriver(onErrorJustReturn: false) }

    private var registrationErrorSubject = PublishRelay<String?>()
    var registrationErrorMessage: Driver<String?> { return registrationErrorSubject.asDriver(onErrorJustReturn: nil) }

    // MARK: - Initialization

    init(input: RegistrationModuleInput,
         coordinator: AuthorizationCoordinator?,
         emailValidator: BaseValidator = EmailValidatorImpl(),
         passwordValidator: BaseValidator = PasswordValidatorImpl(),
         nameValidator: BaseValidator = NameValidatorImpl(),
         authorizationService: AuthorizationService = AuthorizationServiceImpl(),
         cellFactory: RegistrationInputCellFactory = RegistrationInputCellFactoryImpl()) {
        self.coordinator = coordinator
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.nameValidator = nameValidator
        self.authorizationService = authorizationService
        self.cellFactory = cellFactory

        emailInputSubject.accept(input.email)

        let factoryInput = RegistrationInputCellFactoryImpl.Input(emailInputSubject: emailInputSubject,
                                                                  isEmailInputViewActive: isEmailInputViewActive,
                                                                  emailErrorMessageSubject: emailErrorMessageSubject,
                                                                  passwordInputSubject: passwordInputSubject,
                                                                  isPasswordInputViewActive: isPasswordInputViewActive,
                                                                  passwordErrorMessageSubject: passwordErrorMessageSubject,
                                                                  repeatPasswordInputSubject: repeatPasswordInputSubject,
                                                                  isRepeatPasswordInputViewActive: isRepeatPasswordInputViewActive,
                                                                  repeatPasswordErrorMessageSubject: repeatPasswordErrorMessageSubject,
                                                                  externalRepeatPasswordErrorMessageSubject: externalRepeatPasswordErrorMessageSubject,
                                                                  nameInputSubject: nameInputSubject,
                                                                  isNameInputViewActive: isNameInputViewActive,
                                                                  nameErrorMessageSubject: nameErrorMessageSubject)
        dataSourceSubject.accept(cellFactory.makeRegistrationCells(input: factoryInput))

        prepareSubjects()
    }

    // MARK: - Private

    private func prepareSubjects() {
        registrationTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.isLoadingSubject.accept(true)
            })
            .disposed(by: disposeBag)

        var registrationData: Observable<(String?, String?, String?, String?)> {
            return Observable.combineLatest(emailInputSubject.asObservable(),
                                            nameInputSubject.asObservable(),
                                            passwordInputSubject.asObservable(),
                                            repeatPasswordInputSubject.asObservable()) { email, name, password, repeatPassword in
                return (email, name, password, repeatPassword)
            }
        }

        registrationTrigger
            .withLatestFrom(registrationData)
            .flatMapLatest { [weak self] (email, name, password, _) -> Observable<Event<(String, String)>> in
                guard let self = self, let email = email, let name = name, let password = password else { return .never() }
                return self.authorizationService.register(email: email, name: name, password: password)
                    .materialize()
                    .delay(.seconds(2), scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: { [weak self] event in
                self?.isLoadingSubject.accept(false)
                switch event {
                case .next((let email, let name)):
                    self?.coordinator?.openRegistrationFinish(email: email, name: name)
                case .error(let error):
                    self?.registrationErrorSubject.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        let isValidData = registrationData
            .map({ [weak self] (email, name, password, repeatPassword) -> Bool in
                guard let self = self else { return true }

                let emailValidation = self.emailValidator.validate(email)
                let passwordValidation = self.passwordValidator.validate(password)
                let repeatPasswordValidation = self.passwordValidator.validate(repeatPassword)
                let nameValidation = self.nameValidator.validate(name)

                return emailValidation.isValid
                && nameValidation.isValid
                && passwordValidation.isValid
                && repeatPasswordValidation.isValid
                && password == repeatPassword
            })

        Observable.combineLatest(isValidData,
                                 isEmailInputViewActive.asObservable(),
                                 isNameInputViewActive.asObservable(),
                                 isPasswordInputViewActive.asObservable(),
                                 isRepeatPasswordInputViewActive.asObservable(),
                                 isLoadingSubject.asObservable()) { isValidCredentials,
                                                                    isEmailTextFieldActive,
                                                                    isNameTextFieldActive,
                                                                    isPasswordTextFieldActive,
                                                                    isRepeatPasswordTextFieldActive,
                                                                    isLoading in
            return isValidCredentials
                && !isEmailTextFieldActive
                && !isNameTextFieldActive
                && !isPasswordTextFieldActive
                && !isRepeatPasswordTextFieldActive
                && !isLoading
        }
                                 .bind(to: isRegistrationEnabledSubject)
                                 .disposed(by: disposeBag)

        let passwordsReadyForValidation = Observable.combineLatest(passwordInputSubject.asObservable(),
                                                                   repeatPasswordInputSubject.asObservable(),
                                                                   passwordErrorMessageSubject.asObservable(),
                                                                   repeatPasswordErrorMessageSubject.asObservable()) {
            password,
            repeatPassword,
            passwordError,
            repeatPasswordError in

            return !(password?.isEmpty ?? true)
            && !(repeatPassword?.isEmpty ?? true)
            && passwordError == nil
            && repeatPasswordError == nil
        }

        let passwordInputIsNotActive = isPasswordInputViewActive
            .asObservable()
            .filter({ !$0 })

        let repeatPasswordInNotActive = isRepeatPasswordInputViewActive
            .asObservable()
            .filter({ !$0 })

        let shouldPasswordBeValidate = Observable.merge(passwordInputIsNotActive, repeatPasswordInNotActive)
            .withLatestFrom(passwordsReadyForValidation)

        shouldPasswordBeValidate
            .filter({ $0 })
            .withLatestFrom(registrationData)
            .map { (_, _, password, repeatPassword) -> String? in
                return password == repeatPassword ? nil : "Passwords doesn't match"
            }
            .bind(to: externalRepeatPasswordErrorMessageSubject)
            .disposed(by: disposeBag)

        isRepeatPasswordInputViewActive
            .filter({ $0 })
            .map({ _ in nil })
            .bind(to: externalRepeatPasswordErrorMessageSubject)
            .disposed(by: disposeBag)
    }
}
