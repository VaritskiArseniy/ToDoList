//
//  ListViewModel.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation

protocol ListViewModelInterface {
    func fetchNotes(completion: @escaping ([NoteModel]) -> Void)
}

class ListViewModel {
    private weak var output: ListOutput?
    weak var view: ListViewControllerInterface?
    
    private var todoUseCase: TodoUseCase
    
    init(output: ListOutput, todoUseCase: TodoUseCase) {
        self.output = output
        self.todoUseCase = todoUseCase
    }
    
    func getStartNotes() {
        todoUseCase.fetchJsonNotes()
    }
    
    func fetchNotes(completion: @escaping ([NoteModel]) -> Void) {
        CoreDataManager.shared.fetchNotes { notes in
            let noteModels = notes.map { note in
                NoteModel(id: note.id, title: note.title ?? "", decs: note.desc ?? "", date: note.date ?? "", completed: note.completed)
            }
            
            DispatchQueue.main.async {
                completion(noteModels)
            }
        }
    }

    func showAdd() {
        output?.showAdd()
    }
    
}

extension ListViewModel: ListViewModelInterface { }
