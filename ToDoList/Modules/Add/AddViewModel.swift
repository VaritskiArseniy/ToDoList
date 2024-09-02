//
//  AddViewModel.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 1.09.24.
//

import Foundation


protocol AddViewModelInterface {
}

class AddViewModel {
    private weak var output: AddOutput?
    weak var view: AddViewControllerInterface?
        
    init(output: AddOutput) {
        self.output = output
    }
    
}

extension AddViewModel: AddViewModelInterface { }
