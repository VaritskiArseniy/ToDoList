//
//  TodoUseCase.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 30.08.24.
//

import Foundation


protocol TodoUseCase {
    func fetchJsonNotes()
}


class TodoUseCaseImplementation: TodoUseCase {

    let jsonString = "https://dummyjson.com/todos"

    func fetchJsonNotes() {
        guard let url = URL(string: jsonString) else {
            print("Invalid URL string")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                CoreDataManager.shared.saveTodos(from: jsonString)
            } else {
                print("Failed to convert data to String")
            }
        }

        task.resume()
    }
}

