//
//  ListViewController.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import UIKit
import RswiftResources
import SnapKit

protocol ListViewControllerInterface: AnyObject { }

class ListViewController: UIViewController {
    
    private let viewModel: ListViewModel
    
    private var noteModels: [NoteModel] = []
    
    private enum Constants {
        static var backgroundColor = { R.color.cF7F7F7() }
        static var addImage = { R.image.addImage() }
        static var cellIndificator = { "cellIndificator" }
    }
    
    private let noteTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.addImage(), for: .normal)
        button.addTarget(self, action: #selector(addButtonPress), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchNotes()
        noteTableView.reloadData()
    }
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.backgroundColor()
        setupTableView()
        view.addSubviews([noteTableView, addButton])
        self.viewModel.getStartNotes()
    }
    
    private func setupConstraints() {
        noteTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.size.equalTo(100)
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupTableView() {
        noteTableView.register(ListTableViewCell.self, forCellReuseIdentifier: Constants.cellIndificator())
        noteTableView.delegate = self
        noteTableView.dataSource = self
    }
    
    @objc
    private func addButtonPress() {
        viewModel.showAdd()
    }
    
    private func fetchNotes() {
        viewModel.fetchNotes { [weak self] notes in
            guard let self = self else { return }
            
            self.noteModels = notes.sorted {
                let date1 = self.stringToDate($0.date)
                let date2 = self.stringToDate($1.date)
                
                if let date1 = date1, let date2 = date2 {
                    if date1 != date2 {
                        return date1 > date2
                    }
                }
                return $0.id > $1.id
            }
            
            self.noteTableView.reloadData()
        }
    }
    
    private func stringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.date(from: dateString)
    }
}

extension ListViewController: ListViewControllerInterface { }

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.cellIndificator(),
            for: indexPath
        ) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(model: noteModels[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectNote = noteModels[indexPath.item]
        let noteVC = ChangeViewController(viewModel: ChangeViewModel())
        noteVC.noteModel = selectNote
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete = noteModels[indexPath.row]
            CoreDataManager.shared.deleteNote(with: noteToDelete.id)
            noteModels.remove(at: indexPath.row)
            noteTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ListViewController: ListTableViewCellDelegate {
    func didTapCheckmark(in cell: ListTableViewCell) {
        guard let indexPath = noteTableView.indexPath(for: cell) else { return }
        
        var note = noteModels[indexPath.row]
        
        note.completed.toggle()
        
        CoreDataManager.shared.updateNoteCompletionStatus(note: note)
        fetchNotes()
        noteTableView.reloadData()
    }
}
