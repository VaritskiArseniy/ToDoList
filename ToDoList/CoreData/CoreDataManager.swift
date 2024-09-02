//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation
import UIKit
import CoreData

final class CoreDataManager: NSObject {
    static let shared = CoreDataManager()
    private override init() {}
    
    private var appDelegate: AppDelegate? {
        if Thread.isMainThread {
            return UIApplication.shared.delegate as? AppDelegate
        } else {
            var delegate: AppDelegate?
            DispatchQueue.main.sync {
                delegate = UIApplication.shared.delegate as? AppDelegate
            }
            return delegate
        }
    }

    var context: NSManagedObjectContext? {
        guard let appDelegate = appDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext

    }
    
    func logCoreDataDBPath() {
        if let url = appDelegate?.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url {
            print("DB url - \(url)")
        }
    }
    
    func createNote(with id: Int16, title: String, desc: String, date: String, completed: Bool) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            guard let contextApp = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }
            
            guard let noteEntityDescription = NSEntityDescription.entity(forEntityName: "Note", in: contextApp) else {
                return
            }
            
            let note = Note(entity: noteEntityDescription, insertInto: self.context)
            note.id = id
            note.title = title
            note.desc = desc
            note.date = date
            note.completed = completed
            self.saveContext()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }
    
    func fetchNotes(completion: @escaping ([Note]) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            
            guard let contextApp = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }
            
            let notes = (try? contextApp.fetch(fetchRequest) as? [Note]) ?? []
            
            DispatchQueue.main.async {
                completion(notes)
            }
        }
    }
    
    func fetchNote(with id: Int16, completion: @escaping (Note?) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            guard let contextApp = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }
            
            let notes = (try? contextApp.fetch(fetchRequest) as? [Note]) ?? []
            let note = notes.first
            
            DispatchQueue.main.async {
                completion(note)
            }
        }
    }
    
    func updateNote(with id: Int16, title: String, desc: String, date: String, completed: Bool) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            
            do {
                
                guard let contextApp = self.context else {
                  print("Failed to save notes: Core Data context is unavailable.")
                  return
                }
                
                guard let notes = try? contextApp.fetch(fetchRequest) as? [Note],
                      let note = notes.first(where: { $0.id == id }) else { return }
                
                note.title = title
                note.desc = desc
                note.date = date
                note.completed = completed
                
                self.saveContext()
            }
        }
    }
    
    func updateNoteCompletionStatus(note: NoteModel) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        do {
            
            guard let contextApp = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }
            
            guard let notes = try? contextApp.fetch(fetchRequest) as? [Note],
                  let updateNote = notes.first(where: { $0.id == note.id }) else { return }
            
            updateNote.completed = note.completed
            
            self.saveContext()
        }
    }
    
    func deleteAllNotes() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            
            do {
                
                guard let contextApp = self.context else {
                  print("Failed to save notes: Core Data context is unavailable.")
                  return
                }
                
                let notes = try? contextApp.fetch(fetchRequest) as? [Note]
                notes?.forEach { contextApp.delete($0) }
            }
            
            self.saveContext()
            
        }
    }
    
    func deleteNote(with id: Int16) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            
            do {
                guard let contextApp = self.context else {
                  print("Failed to save notes: Core Data context is unavailable.")
                  return
                }
                
                guard let notes = try? contextApp.fetch(fetchRequest) as? [Note],
                let note = notes.first(where: { $0.id == id }) else { return }
                
                contextApp.delete(note)
                
                self.saveContext()
            }
        }
    }
    
    func saveTodos(from json: String) {
      DispatchQueue.global(qos: .background).async { [weak self] in
        guard let self = self else { return }

        guard let jsonData = json.data(using: .utf8) else { return }

        do {
          let decoder = JSONDecoder()
          let response = try decoder.decode(TodoResponse.self, from: jsonData)
          let currentDate = self.dateFormatter.string(from: Date())

          for todo in response.todos {
            guard let context = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }

            context.perform {
              if self.isNoteExists(withId: Int16(todo.id)) {
                print("Note with id \(todo.id) already exists, skipping creation.")
              } else {
                self.createNote(with: Int16(todo.id), title: todo.todo, desc: "", date: currentDate, completed: todo.completed)
              }
            }
          }
        } catch {
          print("Failed to decode JSON: \(error.localizedDescription)")
        }
      }
    }

    private func isNoteExists(withId id: Int16) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        guard let contextApp = self.context else {
          print("Failed to save notes: Core Data context is unavailable.")
          return false
        }
        
        let count = (try? contextApp.count(for: fetchRequest)) ?? 0
        return count > 0
    }
    
    private func saveContext() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let contextApp = self.context else {
              print("Failed to save notes: Core Data context is unavailable.")
              return
            }
            
            do {
                try contextApp.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}
