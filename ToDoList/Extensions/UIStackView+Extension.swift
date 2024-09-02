//
//  UIStackView+Extension.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
