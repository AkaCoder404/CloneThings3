//
//  TodoListTask.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CoreData

/// A checbox for a task
struct iOSCheckboxToggleStyle: ToggleStyle {
    @State private var circleScale: CGFloat = 0
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            // If we’re transitioning from OFF to ON, trigger the circle animation.
            if !configuration.isOn {
                withAnimation(.spring(duration: 0.6)) {
                    circleScale = 1.5
                }
                // After 0.6s, reset circleScale back to 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    circleScale = 0
                }
            }
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
            // Customize colors as you prefer
                .foregroundStyle(
                    configuration.isOn ? .white : .primary,
                    configuration.isOn ? .blue : Color.primary.opacity(0.2)
                )
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .scaleEffect(circleScale)
                        .opacity(circleScale == 0 ? 0 : 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}


/// A button whose background color changes while being pressed
struct CustomButton<Icon: View>: View {
    var label: String
    var action: () -> Void
    @ViewBuilder var icon: () -> Icon
    
    @State private var isPressed = false  // State to manage the press visually
    
    var body: some View {
        Button(action: action) {  // Button to perform action
            content
        }
        .buttonStyle(PlainButtonStyle())
        .background(isPressed ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing  // Update isPressed based on whether the button is currently being pressed
        }, perform: {})
    }
    
    @ViewBuilder
    private var content: some View {
        HStack {
            icon()  // Display the icon
                .foregroundColor(.white)
                .imageScale(.medium)
            Text(label)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

struct TodoListTask: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: TodoListItemCD
    var isSelected: Bool // expand on select
    var onSelect: () -> Void
    @Binding var isEditingTask : Bool // Show the keyboard close
    @Binding var showDatePickerModal: Bool
    
    var onSwipeRight: () -> Void // New callback for swipe right action
    
    @State private var isTaskDone : Bool //
    
    // State variables for editing
    @State private var isEditingTitle: Bool = false
    @State private var editedTitle: String = ""
    @State private var editedDetails: String = ""
    @FocusState private var editingTitleIsFocused: Bool
    @FocusState private var editingDetailsIsFocused: Bool
    
    // State variables for tas related
    @State private var dueDate: Date?
    
    
    init(task: TodoListItemCD,
         isSelected: Bool,
         onSelect: @escaping () -> Void,
         onSwipeRight: @escaping () -> Void,
         isEditingTask: Binding<Bool> = .constant(false),
         showDatePickerModal: Binding<Bool> = .constant(false)) {
        self.task = task
        self.editedTitle = task.title ?? ""
        self.editedDetails = task.details ?? ""
        self.isSelected = isSelected
        self.onSelect = onSelect
        self._isTaskDone = State(initialValue: task.isDone)
        self._isEditingTask = isEditingTask
        self._showDatePickerModal = showDatePickerModal
        self.onSwipeRight = onSwipeRight
    }
    
    // How far the user has swiped
    @State private var offsetX: CGFloat = 0
    private let maxLeftSwipe: CGFloat = 40     // how far can user swipe left
    private let maxRightSwipe: CGFloat = 40    // how far can user swipe right
    private let leftSwipeThreshold: CGFloat = -20   // how far to trigger left action
    private let rightSwipeThreshold: CGFloat = 20    // how far to trigger right action
    @State private var rowHeight: CGFloat = 0 // ensure the slider and content same heights
    
    // Debounced Save
    @State private var saveWorkItem: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            HStack {
                if offsetX > 0 {
                    // 1) Left-side background (when swiping right, offsetX > 0)
                    ZStack(alignment:.center) {
                        Color.yellow
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(.trailing, 8)
                    }
                    .frame(width: 50)
                    .frame(height: rowHeight)
                    .cornerRadius(8.0, corners: [.topLeft, .bottomLeft])
                }
                Spacer()
                // 2) Right-side background (when swiping left, offsetX < 0)
                if offsetX < 0 {
                    ZStack(alignment:.center) {
                        Color.red
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                    .frame(width: 50)
                    .frame(height: rowHeight)
                    .cornerRadius(8.0, corners: [.topRight, .bottomRight])
                }
            }
            
            // 3) The actual row content
            rowContent
                .offset(x: offsetX)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                // Measure once
                                rowHeight = geo.size.height
                            }
                            .onChange(of: geo.size.height) { _,newHeight in
                                // If the row content expands/collapses
                                rowHeight = newHeight
                            }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            // Only allow swiping if !isSelected
                            guard !isSelected else { return }
                            let translation = value.translation.width
                            
                            // If swiping right, clamp to [0...maxRightSwipe]
                            if translation > 0 {
                                offsetX = min(translation, maxRightSwipe)
                            }
                            // If swiping left, clamp to [-maxLeftSwipe...0]
                            else {
                                offsetX = max(translation, -maxLeftSwipe)
                            }
                        }
                        .onEnded { _ in
                            // Decide what to do after the user lifts their finger
                            endDrag()
                        }
                )
        }
        .animation(.easeInOut, value: offsetX)
    }
    
    private var rowContent: some View {
        VStack {
            HStack(alignment: .top) {
                Toggle(isOn: $isTaskDone) {}
                    .toggleStyle(iOSCheckboxToggleStyle())
                    .onChange(of: isTaskDone) { _, newValue in
                        // Cancel any previously scheduled save
                        saveWorkItem?.cancel()
                        
                        // Create a new work item to be executed in 3 seconds
                        let workItem = DispatchWorkItem {
                            // Check if `isTaskDone` is still `newValue`
                            // If it’s changed again, do nothing.
                            if isTaskDone == newValue {
                                task.isDone = newValue
                                saveContext()
                            }
                        }
                        
                        // Schedule the new work item
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
                        
                        // Keep a reference so we can cancel it if needed
                        saveWorkItem = workItem
                    }
                    .buttonStyle(.plain)
                    .frame(width: 15, height: 15)
                    .padding(.top, 3)
                
                if !isSelected {
                    HStack {
                        if task.dueDate != nil
                            && isTodayMorning(task.dueDate!) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        if task.dueDate != nil
                            && isTodayTonight(task.dueDate!) {
                            Image(systemName: "moon.fill").foregroundColor(.teal)
                        }
                        if task.dueDate != nil
                            && !isTodayMorning(task.dueDate!)
                            && !isTodayTonight(task.dueDate!)
                        {
                            Text(formatDateWithinWeek(task.dueDate!))
                                .font(.footnote)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 3)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(4.0)
                        }
                        Text(task.title ?? "新待事办事项")
                            .lineLimit(1)
                            .truncationMode(.tail)
                        if task.details != "" {
                            Image(systemName: "doc")
                                .font(.footnote)
                        }
                    }
                } else {
                    TextField("新待事办事项", text: $editedTitle, axis: .vertical)
                        .fixedSize(horizontal: false, vertical: true)
                        .focused($editingTitleIsFocused)
                        .onChange(of: editedTitle) {
                            oldValue, newValue in
                            task.title = editedTitle != "" ? editedTitle : "新待事办事项"
                            saveContext()
                        }
                        .onChange(of: editingTitleIsFocused) {
                            oldValue, newValue in
                            withAnimation {
                                isEditingTask = newValue
                            }
                        }
                        .onChange(of: isEditingTask) {
                            oldValue, newValue in
                            if isEditingTask == false {
                                editingTitleIsFocused = false
                            }
                        }
                }
                Spacer()
            }
            .padding(.vertical, 0)
            .contentShape(Rectangle())
            .onTapGesture { onSelect() }
            
            if isSelected {
                VStack(alignment: .leading) {
                    // TODO TextEditor does not have a placeholder...
                    TextEditor(text: $editedDetails)
                        .frame(minHeight: 80) // Adjust the minimum height as needed
                        .font(.footnote)
                        .scrollContentBackground(.hidden)
                        .focused($editingDetailsIsFocused)
                        .onChange(of: editedDetails) { oldValue, newValue in
                            task.details = newValue
                            saveContext()
                        }.onChange(of: editingDetailsIsFocused) {
                            oldValue, newValue in
                            withAnimation {
                                isEditingTask = newValue
                            }
                        }
                        .onChange(of: isEditingTask) {
                            oldValue, newValue in
                            if isEditingTask == false {
                                editingDetailsIsFocused = false
                            }
                        }
                }.frame(maxWidth: .infinity, alignment:.leading)
                    .padding(.horizontal, 18)
                
                HStack {
                    if task.dueDate != nil
                        && !isTodayMorning(task.dueDate!)
                        && !isTodayTonight(task.dueDate!)
                    {
                        CustomButton(label: formatSpecialDates(task.dueDate!), action: { showDatePickerModal = true} ) {
                            Image(systemName: "calendar").foregroundColor(.red)
                        }
                    }
                    if task.dueDate != nil
                        && isTodayMorning(task.dueDate!) {
                        CustomButton(
                            label: "今天",
                            action: { showDatePickerModal = true }
                        ) {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                        }
                    }
                    if task.dueDate != nil
                        && isTodayTonight(task.dueDate!) {
                        CustomButton(
                            label: "今晚",
                            action: { showDatePickerModal = true }
                        ) {
                            Image(systemName: "moon.fill").foregroundColor(.teal)
                        }
                    }
                    Spacer()
                    HStack {
                        if task.dueDate == nil {
                            Button(action: {
                                withAnimation {
                                    showDatePickerModal = true
                                }
                            }) {
                                Image(systemName: "calendar")
                            }.buttonStyle(.plain)
                        }
                        Image(systemName: "tag")
                        Image(systemName: "list.bullet")
                        Image(systemName: "flag")
                    }
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
                .animation(.easeInOut, value: isSelected)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color(.secondarySystemBackground): Color(.secondarySystemBackground))
        .cornerRadius(4)
        //        .shadow(color: isSelected ? Color.gray.opacity(0.4) : Color.clear, radius: 2, x: 0, y: 1)
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
    
    /// Called on drag ended
    private func endDrag() {
        // If swiped far enough right, trigger action
        if offsetX > rightSwipeThreshold {
            print("Show Date Picker")
            provideHapticFeedback()
            onSwipeRight()
        }
        // If swiped far enough left, trigger action
        else if offsetX < leftSwipeThreshold {
            print("Show multi-select")
            provideHapticFeedback()
            // TODO
        }
        resetOffset()
    }
    
    /// Resets the offset to 0 with animation
    private func resetOffset() {
        withAnimation {
            offsetX = 0
        }
    }
    
    private func provideHapticFeedback() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // Choose feedback style
        feedbackGenerator.impactOccurred()
    }
}


#Preview {
    let singleItem = PersistenceController.createSingleTaskPreviewItem()
    let isEditingTask = Binding.constant(false)
    let showDatePickerModal = Binding.constant(false)
    return TodoListTask(task: singleItem, isSelected: false, onSelect: {}, onSwipeRight: {}, isEditingTask: isEditingTask, showDatePickerModal: showDatePickerModal)
        .environment(\.managedObjectContext, PersistenceController.previewTodoListItems.container.viewContext)
}
