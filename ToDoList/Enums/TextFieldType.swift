//
//  TextFieldType.swift
//  ToDoList
//
//  Created by Арсений Варицкий on 2.09.24.
//

import Foundation
import UIKit

enum TextFieldType {
    case title
    case desc

    var label: String {
        switch self {
        case .title:
            return "Заголовок"
            
        case .desc:
            return "Описание"
            
        }
    }
}
