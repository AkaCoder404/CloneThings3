//
//  SwiftReorderableForEach.swift
//  CloneThings3
//
//  Created by George Li on 12/26/24.
//

// Inspired: https://github.com/globulus/swiftui-reorderable-foreach


import SwiftUI
import UniformTypeIdentifiers
import CoreData


// 2) The generic ReorderableForEach view
public struct ReorderableForEach<Data, Content>: View
where Data : Hashable, Content : View {
    @Binding var data: [Data]           // The array to reorder
    @Binding var allowReordering: Bool  // Toggle for enabling drag-and-drop
    
    private let content: (Data, Bool) -> Content
    
    @State private var draggedItem: Data?
    @State private var hasChangedLocation: Bool = false
    
    /// - Parameters:
    ///   - data: binding to the array of items
    ///   - allowReordering: binding to a boolean that determines if drag-and-drop is active
    ///   - content: a closure that returns the view for each item
    public init(_ data: Binding<[Data]>,
                allowReordering: Binding<Bool> = .constant(true),
                @ViewBuilder content: @escaping (Data, Bool) -> Content) {
        _data = data
        _allowReordering = allowReordering
        self.content = content
    }
    
    public var body: some View {
        ForEach(data, id: \.self) { item in
            if allowReordering {
                content(item, hasChangedLocation && draggedItem == item)
                    .onDrag {
                        draggedItem = item
                        // We can provide any unique String representation.
                        // 'hashValue' is good enough to identify the item.
                        return NSItemProvider(object: "\(item.hashValue)" as NSString)
                    }
                    .onDrop(
                        of: [UTType.plainText],
                        delegate: DragRelocateDelegate(
                            item: item,
                            data: $data,
                            draggedItem: $draggedItem,
                            hasChangedLocation: $hasChangedLocation
                        )
                    )
            } else {
                // If we're not allowing reordering, just display the item without drag gestures
                content(item, false)
            }
        }
    }
    
    /// A helper DropDelegate for handling reordering logic
    struct DragRelocateDelegate<Item>: DropDelegate where Item : Equatable {
        let item: Item
        @Binding var data: [Item]
        @Binding var draggedItem: Item?
        @Binding var hasChangedLocation: Bool
        
        func dropEntered(info: DropInfo) {
            guard item != draggedItem,
                  let current = draggedItem,
                  let fromIndex = data.firstIndex(of: current),
                  let toIndex = data.firstIndex(of: item)
            else {
                return
            }
            
            hasChangedLocation = true
            
            // Reorder in memory:
            if data[toIndex] != current {
                withAnimation {
                    data.move(
                        fromOffsets: IndexSet(integer: fromIndex),
                        toOffset: (toIndex > fromIndex) ? toIndex + 1 : toIndex
                    )
                }
            }
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            // We signal that we're moving items, not copying
            DropProposal(operation: .move)
        }
        
        func performDrop(info: DropInfo) -> Bool {
            // Reset state
            hasChangedLocation = false
            draggedItem = nil
            return true
        }
    }
}

// 3) Example usage with TodoListItemCD
//    A simple view that shows how to reorder tasks fetched from Core Data.
struct ReorderingTasksVStackTest: View {
    // Fetch tasks sorted by orderIndex (ascending)
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoListItemCD.orderIndex, ascending: true)],
        animation: .default
    )
    private var fetchedTasks: FetchedResults<TodoListItemCD>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    // Local array containing tasks for the reorderable view
    @State private var localTasks: [TodoListItemCD] = []
    
    // Toggle for enabling reorder
    @State private var allowReordering = false
    
    var body: some View {
        VStack(spacing: 24) {
            Toggle("Allow Reordering", isOn: $allowReordering)
                .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                ReorderableForEach($localTasks, allowReordering: $allowReordering) { item, isDragged in
                    // Display each task’s content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title ?? "Untitled Task")
                            .font(.headline)
                        Text(item.details ?? "No details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    // Highlight if currently dragged
                    .overlay(isDragged ? Color.white.opacity(0.6) : Color.clear)
                }
            }
            .padding(.horizontal)
            
            // Button to save changes back to Core Data
            Button("Save Order to Core Data") {
                // Reassign orderIndex based on the current arrangement
                for (index, task) in localTasks.enumerated() {
                    task.orderIndex = Int64(index)
                }
                saveContext()
            }
            .padding(.bottom)
        }
        .onAppear {
            // On appear, copy from fetchedTasks into localTasks
            localTasks = Array(fetchedTasks)
        }
        .onChange(of: fetchedTasks.map { $0 }) { _, newItems in
            // If the fetch results change externally, keep localTasks in sync
            localTasks = newItems
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context after reorder: \(error)")
        }
    }
}

// MARK: - Preview
struct ReorderingTasksVStackTest_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a mock or real container
        // e.g., PersistenceController.preview.container.viewContext
        let context = PersistenceController.preview.container.viewContext
        
        return NavigationView {
            ReorderingTasksVStackTest()
                .environment(\.managedObjectContext, context)
        }
    }
}
