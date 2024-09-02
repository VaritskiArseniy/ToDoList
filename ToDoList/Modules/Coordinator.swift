//
//  Coordinator.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation
import UIKit

final class Coordinator {
    
    private let assembly: Assembly
    private var navigationController = UINavigationController()
        
    init(assembly: Assembly) {
        self.assembly = assembly
    }
    
    func startList(window: UIWindow) {
        let viewController = assembly.makeList(output: self)
        navigationController = .init(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension Coordinator: ListOutput {
    func showAdd() {
        let viewController = assembly.makeAdd(output: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension Coordinator: AddOutput { }
