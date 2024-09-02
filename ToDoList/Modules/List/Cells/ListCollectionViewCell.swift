//
//  ListTableViewCell.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import UIKit

protocol ListTableViewCellDelegate: AnyObject {
    func didTapCheckmark(in cell: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    
    weak var delegate: ListTableViewCellDelegate?
    
    private enum Constants {
        static var grey60Color = { R.color.c3C3C43p60() }
        static var grey13Color = { R.color.c3C3C43p13() }
        static var greyColor = { R.color.c8E8E93() }
    }
    
    private lazy var dateLabel: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.text = "noDate"
        label.textColor = .black
        return label
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = Constants.grey13Color()
        return separator
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textColor = Constants.greyColor()
        return label
    }()
    
    private lazy var descStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "checkmark.circle")
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(checkPress))
        imageView.addGestureRecognizer(tapRecognizer)
        return imageView
    }()
    
    private var spaceView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        descStackView.addArrangedSubview(titleLabel)
        descStackView.addArrangedSubview(descLabel)
        mainStackView.addArrangedSubview(dateLabel)
        mainStackView.addArrangedSubview(separator)
        mainStackView.addArrangedSubview(descStackView)
        mainStackView.addArrangedSubview(checkImageView)
        mainStackView.addArrangedSubview(spaceView)
        contentView.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        mainStackView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.width.equalTo(39)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(18)
        }
        
        separator.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(0.5)
        }
        
        descStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
        }
        
        checkImageView.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        spaceView.snp.makeConstraints {
            $0.size.equalTo(8)
        }
    }
    
    @objc
    private func checkPress() {
        delegate?.didTapCheckmark(in: self)
    }
    
    func configure(model: NoteModel) {
        titleLabel.text = model.title
        dateLabel.text = model.date
        descLabel.text = model.decs
        if model.completed {
            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            checkImageView.image = UIImage(systemName: "checkmark.circle")
        }
    }
}
