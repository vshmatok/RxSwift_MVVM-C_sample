//
//  RegistrationInputTableViewCell.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 10.04.2022.
//

import RxCocoa
import RxSwift
import UIKit

// MARK: - Protocol

protocol RegistrationCellView: AnyObject {
    func configure(with viewModel: RegistrationInputCellViewModel)
}

final class RegistrationInputTableViewCell: UITableViewCell {

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)

        return label
    }()

    private lazy var inputTextField: UITextField = {
        let textField = UITextField()

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.boldSystemFont(ofSize: 14)
        textField.textColor = .gray

        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 10)

        return label
    }()

    // MARK: - Properties

    private var validator: BaseValidator!

    private var inputSubject: BehaviorRelay<String?>!
    private var isInputViewActive: PublishRelay<Bool>!
    private var errorMessageSubject: BehaviorRelay<String?>!
    private var externalRepeatPasswordErrorMessageSubject: BehaviorRelay<String?>!


    private var disposeBag: DisposeBag = DisposeBag()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    // MARK: - Private

    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(inputTextField)
        contentView.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: inputTextField.topAnchor, constant: -8),

            inputTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            inputTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            inputTextField.bottomAnchor.constraint(equalTo: errorLabel.topAnchor),

            errorLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            errorLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }

    private func bindUI() {
        let inputBeginEditingObservable = inputTextField.rx.controlEvent(.editingDidBegin).asObservable()
            .map({ _ in true })
        let inputEndEditingObservable = inputTextField.rx.controlEvent(.editingDidEnd).asObservable()
            .map({ _ in false })
        Observable.merge(inputBeginEditingObservable,
                         inputEndEditingObservable).bind(to: isInputViewActive).disposed(by: disposeBag)

        let isInputViewActive = isInputViewActive.asObservable().share(replay: 1)

        isInputViewActive
            .filter({ !$0 })
            .withLatestFrom(inputSubject.asObservable())
            .map { [weak self] input -> String? in
                let validation = self?.validator.validate(input)
                return validation?.errorMessage
            }
            .bind(to: errorMessageSubject)
            .disposed(by: disposeBag)

        isInputViewActive
            .filter({ $0 })
            .map({ _ in nil })
            .bind(to: errorMessageSubject)
            .disposed(by: disposeBag)

        Observable.combineLatest(errorMessageSubject.asObservable(),
                                 externalRepeatPasswordErrorMessageSubject.asObservable()) { errorMessage, externalRepeatPasswordError in
            return errorMessage ?? externalRepeatPasswordError
        }
                                 .asDriver(onErrorJustReturn: nil)
                                 .drive(errorLabel.rx.text)
                                 .disposed(by: disposeBag)

        inputSubject.take(1).asDriver(onErrorJustReturn: nil).drive(inputTextField.rx.text).disposed(by: disposeBag)
        inputTextField.rx.text.bind(to: inputSubject).disposed(by: disposeBag)
    }
}

// MARK: - RegistrationCellView

extension RegistrationInputTableViewCell: RegistrationCellView {
    func configure(with viewModel: RegistrationInputCellViewModel) {
        selectionStyle = .none

        self.validator = viewModel.validator

        self.inputSubject = viewModel.rx.inputSubject
        self.isInputViewActive = viewModel.rx.isInputViewActive
        self.errorMessageSubject = viewModel.rx.errorMessageSubject
        self.externalRepeatPasswordErrorMessageSubject = viewModel.rx.externalErrorSubject

        titleLabel.text = viewModel.ui.title
        inputTextField.attributedPlaceholder = NSAttributedString(string: viewModel.ui.placeholder,
                                                                  attributes: [.font: UIFont.systemFont(ofSize: 14)])
        inputTextField.returnKeyType = viewModel.ui.returnKeyType
        inputTextField.keyboardType = viewModel.ui.keyboardType

        bindUI()
    }
}
