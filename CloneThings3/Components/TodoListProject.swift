//
//  TodoListGroup.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

struct TodoListProject : View {
    @ObservedObject var project: TodoListItemCD
    @Environment(\.managedObjectContext) private var viewContext
    
    /// The UUID of the project that was just created in `MainView`.
    /// If `project.id` matches this, we know this is the brand-new project row.
    @Binding var newlyCreatedProjectID: UUID?
    // Local states for handling editing.
    @FocusState private var isTitleFocused: Bool
    @State private var newTitle: String = ""
    @State private var isEditing: Bool = false
    
    /// [START] Code to update the project when ProjectView's project changes
    // 1. Add a FetchRequest to fetch tasks related to this project
    @FetchRequest var tasks: FetchedResults<TodoListItemCD>
    
    // 2. Computed property to calculate progress based on fetched tasks
    private var progress: Float {
        let total = Float(tasks.count)
        guard total > 0 else { return 0 }
        let completed = Float(tasks.filter { $0.isDone }.count)
        return completed / total
    }
    // 3. Initialize the FetchRequest with a predicate to fetch tasks for the current project
    init(project: TodoListItemCD, newlyCreatedProjectID: Binding<UUID?> = .constant(nil)) {
        self.project = project
        self._newlyCreatedProjectID = newlyCreatedProjectID
        _newTitle = State(initialValue: project.title ?? "")
        
        //
        self._tasks = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TodoListItemCD.dueDate, ascending: true)],
            predicate: NSPredicate(format: "projectId == %@", project.id! as CVarArg),
            animation: .default
        )
    }
    /// [END]
    
    var body : some View {
        NavigationLink(destination: ProjectView(project: project)) {
            HStack {
                PieProgress(progress: Float(progress), radius:8).frame(width: 15, height: 15)
                
                if isEditing {
                    TextField(project.title ?? "新建项目", text: $newTitle, onCommit: {
                        withAnimation {
                            newlyCreatedProjectID = nil
                        }
                    })
                    .textFieldStyle(.plain)
                    .focused($isTitleFocused)
                    .onChange(of: newTitle) {
                        project.title = newTitle;
                    }
                    .onChange(of: newlyCreatedProjectID) {
                        isEditing = false
                    }
                    .onAppear {
                        // Delay to ensure SwiftUI’s layout is ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isTitleFocused = true
                        }
                    }
                }
                else {
                    Text(project.title ?? "新建项目")
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }.padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .background(isEditing ? Color(.secondarySystemBackground) : Color(.systemBackground) )
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                // If *this* row is the newly created project:
                if project.id == newlyCreatedProjectID {
                    // Immediately go into edit mode.
                    isEditing = true
                }
            }
    }
    
    // Function to Save Core Data Context
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    private func saveTitle() {
        isEditing = false
        project.title = newTitle
        saveContext()
    }
}

#Preview {
    let singleItem = PersistenceController.createSinglePreviewItem()
    return TodoListProject(project: singleItem,
                           newlyCreatedProjectID:  .constant(singleItem.id))
        .environment(\.managedObjectContext, PersistenceController.previewTodoListItems.container.viewContext)
}

