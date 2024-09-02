//
//  MainTextField.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 1.09.24.
//

import Foundation
import UIKit
import SnapKit

protocol MainTextFieldDelegate: AnyObject {
    func shouldReturn(_ mainTextField: MainTextField)
    func textFieldDidChange(_ mainTextField: MainTextField)
}

final class MainTextField: UIView {
    
    private enum Constants {
        static var borderColor = { R.color.c3C3C43p13() }
        static var hintColor = { R.color.c3C3C43p60() }
    }
    
    weak var delegate: MainTextFieldDelegate?
    
    private let toolbar = UIToolbar()
    
    private var type: TextFieldType
    
    private var selectedNote: NoteModel?
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.textColor = .black
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Constants.hintColor()
        ]
        textField.attributedPlaceholder = NSAttributedString(string: type.label, attributes: placeholderAttributes)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return textField
    }()
    
    init(type: TextFieldType) {
        self.type = type
        super.init(frame: .zero)
        setupUI()
        layoutSubviews()
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstraints()
    }
    
    private func setupUI() {
        layer.borderColor = Constants.borderColor()?.cgColor
        layer.borderWidth = 1
        
        layer.cornerRadius = 16
        addSubview(textField)
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    func setupKeyboardType(type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    func getTextField() -> UITextField {
        return textField
    }
    
    func isFilled() -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        
        return true
    }
    
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(self)
    }
}

extension MainTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.shouldReturn(self)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        return
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        return
    }
}
