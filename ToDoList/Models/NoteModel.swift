//
//  NoteModel.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 30.08.24.
//

import Foundation

struct NoteModel {
    let id: Int16
    let title: String
    let decs: String
    let date: String
    var completed: Bool

    init(id: Int16, title: String, decs: String, date: String, completed: Bool) {
        self.id = id
        self.title = title
        self.decs = decs
        self.date = date
        self.completed = completed
    }
}
