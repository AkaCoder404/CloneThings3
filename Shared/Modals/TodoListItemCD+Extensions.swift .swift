//
//  TodoListItemCD+Extensions.swift .swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import Foundation
import CoreData
import SwiftUI

extension TodoListItemCD {
    /// Returns the total number of tasks for the project.
    var totalTasks: Int {
        guard isProject, let id = id else { return 0 }
        let request: NSFetchRequest<TodoListItemCD> = TodoListItemCD.fetchRequest()
        request.predicate = NSPredicate(format: "projectId == %@", id as CVarArg)
        
        do {
            let count = try self.managedObjectContext?.count(for: request) ?? 0
            return count
        } catch {
            print("Error fetching total tasks for project \(title ?? "Untitled"): \(error)")
            return 0
        }
    }
    
    /// Returns the number of completed tasks for the project.
    var completedTasks: Int {
        guard isProject, let id = id else { return 0 }
        let request: NSFetchRequest<TodoListItemCD> = TodoListItemCD.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "projectId == %@", id as CVarArg),
            NSPredicate(format: "isDone == %@", NSNumber(value: true))
        ])
        
        do {
            let count = try self.managedObjectContext?.count(for: request) ?? 0
            return count
        } catch {
            print("Error fetching completed tasks for project \(title ?? "Untitled"): \(error)")
            return 0
        }
    }
    
    /// Returns the progress as a Double between 0.0 and 1.0.
    var progress: Double {
        let total = Double(totalTasks)
        guard total > 0 else { return 0 }
        let completed = Double(completedTasks)
        return completed / total
    }
}
