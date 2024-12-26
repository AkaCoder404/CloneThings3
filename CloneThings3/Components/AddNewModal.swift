//
//  AddNewModal.swift
//  CloneThings3
//
//  Created by George Li on 12/24/24.
//

import SwiftUI

/// A reusable pressable button that highlights on long press
/// and takes up the full available width.
struct PressableRowButton<Label: View>: View {
    var action: () -> Void
    var label: () -> Label
    @State private var isPressed = false

    var body: some View {
        // The entire content is one Button
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                // Highlight the background if being pressed
                .background(isPressed ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(4)
        }
        // Make the entire width of the button pressable
        .contentShape(Rectangle())
        // Use a “plain” button style so we don’t get a default iOS highlight overlay
        .buttonStyle(.plain)
        // Detect a long press & animate the highlight
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

struct AddNewModal: View {
    /// Callback closures for each action
    var createNewInboxTask: () -> Void
    var createNewProject: () -> Void
    var createNewGroup: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) Create New Inbox Task
            PressableRowButton(action: createNewInboxTask) {
                HStack(alignment: .top) {
                    Image(systemName: "plus")
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading) {
                        Text("新建待办事项")
                            .fontWeight(.bold)
                        Text("向收件箱快速添加待办事项")
                            .font(.subheadline)
                    }
                }
            }
            
            // 2) Create New Project
            PressableRowButton(action: createNewProject) {
                HStack(alignment: .top) {
                    Image(systemName: "button.programmable")
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("新建事项")
                            .fontWeight(.bold)
                        Text("定义一个目标，然后每次完成一个待办事项")
                            .font(.subheadline)
                    }
                }
            }
            
            // 3) Create New Group
            PressableRowButton(action: createNewGroup) {
                HStack(alignment: .top) {
                    Image(systemName: "cube")
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("新建区域")
                            .fontWeight(.bold)
                        Text("根据不同的责任群组项目和待办事项，例如家庭或工作")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    AddNewModal(
        createNewInboxTask: { print("Inbox Task Created") },
        createNewProject: { print("Project Created") },
        createNewGroup: { print("Group Created") }
    )
}
