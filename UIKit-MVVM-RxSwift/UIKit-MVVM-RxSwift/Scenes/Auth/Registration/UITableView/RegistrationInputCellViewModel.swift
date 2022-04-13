//
//  RegistrationInputCellViewModel.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import RxSwift
import RxRelay
import UIKit

enum RegistrationCellKind: CaseIterable {

    // MARK: - Cases

    case email
    case password
    case repeatPassword
    case name
}

class RegistrationInputCellViewModel {

    // MARK: - UI

    struct UI {

        // MARK: - Properties

        let title: String
        let placeholder: String
        let returnKeyType: UIReturnKeyType
        let keyboardType: UIKeyboardType
    }

    // MARK: - Rx

    struct Rx {

        // MARK: - Properties

        var inputSubject: BehaviorRelay<String?>!
        var isInputViewActive: PublishRelay<Bool>!
        var errorMessageSubject: BehaviorRelay<String?>!
        var externalErrorSubject: BehaviorRelay<String?>!
    }

    // MARK: - Protocol

    var identifier: String = RegistrationInputTableViewCell.className
    var kind: RegistrationCellKind
    var validator: BaseValidator
    var ui: UI
    var rx: Rx

    // MARK: - Initialization

    init(kind: RegistrationCellKind, ui: RegistrationInputCellViewModel.UI, rx: Rx, validator: BaseValidator) {
        self.kind = kind
        self.ui = ui
        self.rx = rx
        self.validator = validator
    }
}
