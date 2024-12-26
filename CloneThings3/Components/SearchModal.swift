//
//  SearchModal.swift
//  CloneThings3
//
//  Created by George Li on 12/25/24.
//

import Foundation
import SwiftUI
import CoreData

struct CustomTextButton<Label: View>: View {
    var action: () -> Void
    var label: () -> Label // Generic for label view
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                label()
                    .foregroundColor(.primary)
            }
            .background(isPressed ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(4)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .onTapGesture {
            action()
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}


class SearchViewModel: ObservableObject {
    @Published var items: [TodoListItemCD] = []
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Perform a manual fetch with a dynamic predicate
    func search(for query: String) {
        let request = NSFetchRequest<TodoListItemCD>(entityName: "TodoListItemCD")
        
        // If the query isn't empty, filter by title
        if !query.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        }
        
        // Sort as desired
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            self.items = results
        } catch {
            print("Fetch error: \(error)")
            self.items = []
        }
    }
}

struct CustomImageLabelButton<LeadingContent: View, Label: View>: View {
    var action: () -> Void
    var leadingContent: () -> LeadingContent // Generic for leading view
    var label: () -> Label // Generic for label view
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                leadingContent() // Use the provided leading content
                label()
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 5)
            .background(isPressed ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(4)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .onTapGesture {
            action()
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

struct SearchModal : View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: SearchViewModel
    @Binding var showModal: Bool
    
    @FocusState var isSearchFocused: Bool
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    
    
    init(context: NSManagedObjectContext, showModal: Binding<Bool>) {
        // We must initialize _viewModel with a fresh StateObject
        // Note: This custom init ensures we can pass in the context
        _viewModel = StateObject(wrappedValue: SearchViewModel(context: context))
        self._showModal = showModal
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Search Box with Icons
                HStack {
                    Image(systemName: "magnifyingglass").padding(.leading, 4)
                    
                    TextField("快速查找", text: $searchText, onEditingChanged: { isEditing in self.showCancelButton = true })
                        .foregroundColor(.primary)
                    
                    Button(action: { self.searchText = "" }) {
                        Image(systemName: "xmark")
                            .opacity(searchText == "" ? 0 : 1)
                            .padding(.trailing, 4)
                    }
                }
                .padding(.vertical, 8)
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4.0)
                
                CustomTextButton(action: { withAnimation { showModal = false }
                }, label: {
                    Text("取消")
                        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                })
            }
            .onChange(of: searchText) { _, newValue in
                viewModel.search(for: newValue)
            }.padding(.bottom, 8)
            
            if searchText == "" {
                Text("快速切换列表，查找待办事项，搜索标签...")
                    .foregroundColor(Color.secondary)
                    .padding()
            } else {
                
                // Projects
                VStack {
                    ForEach(viewModel.items) { item in
                        if item.isProject {
                            TodoListProject(project: item)
                        }
                    }
                    
                }
                
                if !viewModel.items.isEmpty {
                    Divider()
                }
                
                // Tasks
                VStack {
                    ForEach(viewModel.items) { item in
                        if !item.isProject {
                            TodoListTask(task: item,
                                         isSelected: false,
                                         onSelect: {},
                                         onSwipeRight: {})
                        }
                    }
                }
                
                // TODO Navigation
                CustomImageLabelButton(
                    action: {},
                    leadingContent: {
                        Image(systemName: "magnifyingglass")
                    },
                    label: {
                        Text("继续搜索")
                    }
                ).background(viewModel.items.isEmpty ? Color.blue.opacity(0.1) : Color.clear)
            }
        } .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(8.0)
            .padding(.horizontal, 20)
    }
}


#Preview {
    let context = PersistenceController.previewTodoListItems.container.viewContext
    return SearchModal(context: context, showModal: .constant(true))
        .environment(\.managedObjectContext, context)
}
