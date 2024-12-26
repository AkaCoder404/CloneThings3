//
//  TodoListTaskAnimated.swift
//  CloneThings3
//
//  Created by George Li on 12/20/24.
//

import Foundation
import SwiftUI

struct TodoListTaskAnimated: View {
    @ObservedObject var task: TodoListItemCD
    var isSelected: Bool
    var onSelect: () -> Void
    var namespace: Namespace.ID // Add namespace

    @Environment(\.managedObjectContext) private var viewContext
    @State private var isOn: Bool

    init(task: TodoListItemCD, isSelected: Bool, onSelect: @escaping () -> Void, namespace: Namespace.ID) {
        self.task = task
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.namespace = namespace
        self._isOn = State(initialValue: task.isDone)
    }

    var body: some View {
        VStack {
            HStack {
                Toggle(isOn: $isOn) {}
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .onChange(of: isOn) { oldValue, newValue in
                        task.isDone = newValue
                        saveContext()
                    }
                    .buttonStyle(.plain)
                    .matchedGeometryEffect(id: task.id ?? UUID(), in: namespace) // Apply matchedGeometryEffect

                Text(task.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }

            if isSelected {
                VStack(alignment: .leading, spacing: 10) {
                    Text(task.details ?? "No Details")
                        .padding(.bottom, 10)

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
                }
                .padding(.leading, 28)
                .matchedGeometryEffect(id: "details\(task.id ?? UUID())", in: namespace) // Separate matchedGeometryEffect for details
                .transition(.opacity)
                .animation(.easeInOut, value: isSelected)
            }
        }
        .background(isSelected ? Color.secondary.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(4)
        .shadow(color: isSelected ? Color.gray.opacity(0.4) : Color.clear, radius: 2, x: 0, y: 1)
        .animation(.easeInOut, value: isSelected)
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
