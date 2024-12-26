//
//  ExpandedTaskView.swift
//  CloneThings3
//
//  Created by George Li on 12/20/24.
//

import Foundation
import SwiftUI

struct ExpandedTaskView: View {
    @ObservedObject var task: TodoListItemCD
    var namespace: Namespace.ID
    var onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isOn: Bool
    
    init(task: TodoListItemCD, namespace: Namespace.ID, onDismiss: @escaping () -> Void) {
        self.task = task
        self.namespace = namespace
        self.onDismiss = onDismiss
        self._isOn = State(initialValue: task.isDone)
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Toggle(isOn: $isOn) {
                        Text(task.title ?? "")
                            .font(.headline)
                    }
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .onChange(of: isOn) { oldValue, newValue in
                        task.isDone = newValue
                        saveContext()
                    }
                    Spacer()
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title)
                    }
                }
                
                Text(task.details ?? "No Details")
                    .font(.body)
                
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "calendar")
                        Text("移动")
                    }
                    Button(action: {}) {
                        Image(systemName: "trash")
                        Text("删除")
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                        Text("更多")
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom))
            .matchedGeometryEffect(id: task.id ?? UUID(), in: namespace)
        }
        .animation(.spring(), value: task)
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
