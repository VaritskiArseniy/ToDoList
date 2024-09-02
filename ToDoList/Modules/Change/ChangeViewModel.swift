//
//  ChangeViewModel.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 1.09.24.
//

import Foundation

protocol ChangeViewModelInterface { }

class ChangeViewModel {
    private weak var output: ChangeOutput?
    weak var view: ChangeViewControllerInterface?
        
    init(output: ChangeOutput? = nil) {
        self.output = output
    }
}

extension ChangeViewModel: ChangeViewModelInterface { }
