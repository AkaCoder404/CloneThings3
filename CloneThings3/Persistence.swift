//
//  Persistence.swift
//  CloneThings3
//
//  Created by George Li on 12/1/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // For the preview page
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // todo previews
    static var previewTodoListItems: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<3 {
            let newItem = TodoListItemCD(context: viewContext)
            newItem.id = UUID()
            newItem.title = "新建项目 \(i)"
            newItem.details = "新建项目 \(i) 的备注"
            newItem.isProject = true
            
            // TODO Give it some children
        }
    
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CloneThings3")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// Add this extension to provide a single item for previews
extension PersistenceController {
    static func createSinglePreviewItem() -> TodoListItemCD {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let singleItem = TodoListItemCD(context: viewContext)
        singleItem.id = UUID()
        singleItem.title = "Single Project Preview"
        singleItem.details = "此项目想向您展示马上开始行动需要知道的一切信息。导出逛逛吧，不要犹豫 - 您可以从设置创建一个新的项目"
        singleItem.isProject = true

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return singleItem
    }
}

extension PersistenceController {
    static func createSingleTaskPreviewItem() -> TodoListItemCD {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let singleItem = TodoListItemCD(context: viewContext)
        singleItem.id = UUID()
        singleItem.title = "新建任务"
        singleItem.isProject = false
        singleItem.details = "备注"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return singleItem
    }
}


// Redundant
//extension TodoListItemCD: Identifiable {}
