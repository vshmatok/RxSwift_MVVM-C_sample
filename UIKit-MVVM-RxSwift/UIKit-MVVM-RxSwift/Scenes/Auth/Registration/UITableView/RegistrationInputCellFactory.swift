//
//  RegistrationInputCellFactory.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import Foundation
import RxCocoa
import RxRelay

// MARK: - RegistrationInputCellFactory

protocol RegistrationInputCellFactory: AnyObject {
    func makeRegistrationCells(input: RegistrationInputCellFactoryImpl.Input) -> [RegistrationInputCellViewModel]
}

final class RegistrationInputCellFactoryImpl: RegistrationInputCellFactory {

    // MARK: - Input

    struct Input {

        // MARK: - Properties

        var emailInputSubject: BehaviorRelay<String?>
        var isEmailInputViewActive: PublishRelay<Bool>
        var emailErrorMessageSubject: BehaviorRelay<String?>

        var passwordInputSubject: BehaviorRelay<String?>
        var isPasswordInputViewActive: PublishRelay<Bool>
        var passwordErrorMessageSubject: BehaviorRelay<String?>

        var repeatPasswordInputSubject: BehaviorRelay<String?>
        var isRepeatPasswordInputViewActive: PublishRelay<Bool>
        var repeatPasswordErrorMessageSubject: BehaviorRelay<String?>
        var externalRepeatPasswordErrorMessageSubject: BehaviorRelay<String?>

        var nameInputSubject: BehaviorRelay<String?>
        var isNameInputViewActive: PublishRelay<Bool>
        var nameErrorMessageSubject: BehaviorRelay<String?>
    }

    // MARK: - Public

    func makeRegistrationCells(input: RegistrationInputCellFactoryImpl.Input) -> [RegistrationInputCellViewModel] {
        return RegistrationCellKind.allCases.map { kind -> RegistrationInputCellViewModel in
            switch kind {
            case .email:
                let ui = RegistrationInputCellViewModel.UI(title: "Email",
                                                           placeholder: "Enter your email address...",
                                                           returnKeyType: .next,
                                                           keyboardType: .emailAddress)
                let rx = RegistrationInputCellViewModel.Rx(inputSubject: input.emailInputSubject,
                                                           isInputViewActive: input.isEmailInputViewActive,
                                                           errorMessageSubject: input.emailErrorMessageSubject,
                                                           externalErrorSubject: BehaviorRelay<String?>(value: nil))
                return RegistrationInputCellViewModel(kind: .email,
                                                      ui: ui,
                                                      rx: rx,
                                                      validator: EmailValidatorImpl())
            case .password:
                let ui = RegistrationInputCellViewModel.UI(title: "Password",
                                                           placeholder: "Enter your password...",
                                                           returnKeyType: .next,
                                                           keyboardType: .default)
                let rx = RegistrationInputCellViewModel.Rx(inputSubject: input.passwordInputSubject,
                                                           isInputViewActive: input.isPasswordInputViewActive,
                                                           errorMessageSubject: input.passwordErrorMessageSubject,
                                                           externalErrorSubject: BehaviorRelay<String?>(value: nil))
                return RegistrationInputCellViewModel(kind: .password,
                                                      ui: ui,
                                                      rx: rx,
                                                      validator: PasswordValidatorImpl())
            case .repeatPassword:
                let ui = RegistrationInputCellViewModel.UI(title: "Repeat password",
                                                           placeholder: "Repeat your password...",
                                                           returnKeyType: .next,
                                                           keyboardType: .default)
                let rx = RegistrationInputCellViewModel.Rx(inputSubject: input.repeatPasswordInputSubject,
                                                           isInputViewActive: input.isRepeatPasswordInputViewActive,
                                                           errorMessageSubject: input.repeatPasswordErrorMessageSubject,
                                                           externalErrorSubject: input.externalRepeatPasswordErrorMessageSubject)
                return RegistrationInputCellViewModel(kind: .repeatPassword,
                                                      ui: ui,
                                                      rx: rx,
                                                      validator: PasswordValidatorImpl())
            case .name:
                let ui = RegistrationInputCellViewModel.UI(title: "Name",
                                                           placeholder: "Enter your name...",
                                                           returnKeyType: .go,
                                                           keyboardType: .default)
                let rx = RegistrationInputCellViewModel.Rx(inputSubject: input.nameInputSubject,
                                                           isInputViewActive: input.isNameInputViewActive,
                                                           errorMessageSubject: input.nameErrorMessageSubject,
                                                           externalErrorSubject: BehaviorRelay<String?>(value: nil))
                return RegistrationInputCellViewModel(kind: .name,
                                                      ui: ui,
                                                      rx: rx,
                                                      validator: NameValidatorImpl())
            }
        }
    }
}
