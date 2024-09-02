//
//  UIView+Extension.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 29.08.24.
//

import Foundation
import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}
