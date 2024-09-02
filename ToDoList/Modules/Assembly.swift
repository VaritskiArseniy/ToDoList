//
//  Assembly.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation
import UIKit

final class Assembly {
    
    var todoUseCase: TodoUseCase {
        TodoUseCaseImplementation()
    }
    
    func makeList(output: ListOutput) -> UIViewController {
        let viewModel = ListViewModel(output: output, todoUseCase: todoUseCase)
        let view = ListViewController(viewModel: viewModel)
        viewModel.view = view
        return view
    }
    
    func makeAdd(output: AddOutput) -> UIViewController {
        let viewModel = AddViewModel(output: output)
        let view = AddViewController(viewModel: viewModel)
        viewModel.view = view
        return view
    }
}
