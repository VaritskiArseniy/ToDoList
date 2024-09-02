//
//  ChangeViewController.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 1.09.24.
//

import UIKit

protocol ChangeViewControllerInterface: AnyObject { }

class ChangeViewController: UIViewController {
    
    private let viewModel: ChangeViewModel
    
    var noteModel: NoteModel?
    
    private enum Constants {
        static var backgroundColor = { R.color.cF7F7F7() }
        static var titleText = { "Добавление заметки" }
        static var saveButtonText = { "Сохранить" }
        static var hintColor = { R.color.c3C3C43p60() }
        static var noLoginButtonColor = { R.color.cF2F2F7() }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText()
        label.font = .boldSystemFont(ofSize: 27)
        label.textColor = .black
        return label
    }()
    
    private lazy var titleTextField: MainTextField = {
        let textField = MainTextField(type: .title)
        textField.delegate = self
        return textField
    }()
    
    private lazy var descTextField: MainTextField = {
        let textField = MainTextField(type: .desc)
        textField.delegate = self
        return textField
    }()
    
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.saveButtonText(), for: .normal)
        button.setTitleColor(Constants.hintColor(), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.backgroundColor = Constants.noLoginButtonColor()
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        canLoginCheck()
    }
    
    init(viewModel: ChangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.backgroundColor()
        stackView.addArrangedSubviews([
            titleTextField,
            descTextField,
            saveButton
        ])
        setupTextFields()
        scrollView.addSubviews([titleLabel, stackView])
        view.addSubviews([scrollView])
    }
    
    private func setupConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top).offset(28)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-20)
            $0.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        
        titleTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.width.equalToSuperview()
        }
        
        descTextField.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.width.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.width.equalToSuperview()
        }
    }
    
    private func canLoginCheck() {
        if titleTextField.isFilled(),
           descTextField.isFilled() {
            saveButton.backgroundColor = .systemBlue
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = Constants.noLoginButtonColor()
            saveButton.setTitleColor(Constants.hintColor(), for: .normal)
            saveButton.isEnabled = false
        }
    }
    
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsiteKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    private func findActiveTextField() -> UIView? {
        for subview in stackView.arrangedSubviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            }
        }
        return nil
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        guard
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        let contentInsets = UIEdgeInsets(
            top: .zero,
            left: .zero,
            bottom: keyboardSize.height,
            right: .zero
        )
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        guard let activeField = findActiveTextField() else { return }
        let textFieldFrame = activeField.convert(activeField.bounds, to: scrollView)
        let visibleRect = CGRect(
            x: .zero,
            y: textFieldFrame.origin.y,
            width: 1,
            height: textFieldFrame.size.height
        )
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc
    private func tapOutsiteKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTextFields() {
        titleTextField.getTextField().text = noteModel?.title
        descTextField.getTextField().text = noteModel?.decs
    }
    
    @objc
    private func saveButtonPress() {
        guard let title = titleTextField.getTextField().text, !title.isEmpty,
              let desc = descTextField.getTextField().text, !desc.isEmpty,
              let id = noteModel?.id,
              let date = noteModel?.date,
              let completed = noteModel?.completed
        else {
            return
        }
        
        CoreDataManager.shared.updateNote(
            with: id,
            title: title,
            desc: desc,
            date: date,
            completed: completed
        )
        
        navigationController?.popViewController(animated: true)
    }
}

extension ChangeViewController: ChangeViewControllerInterface { }

extension ChangeViewController: MainTextFieldDelegate {
    func shouldReturn(_ mainTextField: MainTextField) {
        switch mainTextField.getTextField() {
        case titleTextField.getTextField():
            descTextField.getTextField().resignFirstResponder()
            
        default:
            mainTextField.getTextField().resignFirstResponder()
        }
    }
    
    func textFieldDidChange(_ mainTextField: MainTextField) {
        canLoginCheck()
    }
}
