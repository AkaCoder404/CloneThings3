//
//  NewInboxTaskModal.swift
//  CloneThings3
//
//  Created by George Li on 12/24/24.
//

import Foundation
import SwiftUI

struct NewInboxTaskModal : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Parameters
    var closeButton: () -> Void
    var saveTask: () -> Void
    @ObservedObject var task: TodoListItemCD
    
    @State private var editedTitle: String = ""
    @State private var editedDetails: String = ""
    @FocusState private var isTitleFocused: Bool
    
    init(task: TodoListItemCD, closeButton: @escaping () -> Void, saveTask: @escaping () -> Void) {
        self.task = task
        self.closeButton = closeButton
        self.saveTask = saveTask
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { closeButton() }) {
                    Image(systemName: "xmark")
                        .padding()
                }.buttonStyle(.plain)
            }
            
            VStack {
                // Title
                TextField("新建待办事项",
                          text: Binding(
                            get: { task.title ?? "" },
                            set: { task.title = $0 }
                          ),
                          axis: .vertical
                )
                .font(.body)
                .focused($isTitleFocused)
                
                // Description
                TextField("备注",
                          text: Binding(
                            get: { task.details ?? "" },
                            set: { task.details = $0 }
                          ),
                          axis: .vertical
                )
                .font(.body)
            }.padding(.horizontal)
    
            // Buttons
            HStack {
                Spacer()
                Image(systemName: "calendar")
                Image(systemName: "tag")
                Image(systemName: "list.bullet")
                Image(systemName: "flag")
            }.padding()
            
            // Bottom
            HStack {
                CustomButton(label: "收件箱", action: {}) {
                    Image(systemName: "tray").foregroundColor(.primary)
                }.padding()
                Spacer()
                Button(action: {
                    saveTask()
                }) {
                    Text("存储")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                }
                .background(Color.blue)
                .cornerRadius(4.0)
                .padding()
            }.background(Color(.secondarySystemBackground))
        }.background(Color(.systemBackground))
            .cornerRadius(8.0)
    }
}


#Preview {
    let singleItem = PersistenceController.createSingleTaskPreviewItem()
    return NewInboxTaskModal(task: singleItem, closeButton: {}, saveTask: {}).environment(\.managedObjectContext, PersistenceController.previewTodoListItems.container.viewContext)
}
