//
//  Note+CoreDataProperties.swift
//  
//
//  Created by Арсений Варицкий on 29.08.24.
//
//

import Foundation
import CoreData


public class Note: NSManagedObject {

}

extension Note {

    @NSManaged public var completed: Bool
    @NSManaged public var date: String?
    @NSManaged public var desc: String?
    @NSManaged public var id: Int16
    @NSManaged public var title: String?

}

extension Note: Identifiable {
    
}
