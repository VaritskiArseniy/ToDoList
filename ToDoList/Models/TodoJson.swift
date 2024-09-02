//
//  TodoJson.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 30.08.24.
//

import Foundation

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int16
}

struct TodoResponse: Codable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}
