//
//  CategoryInboxView.swift
//  CloneThings3
//
//  Created by George Li on 12/19/24.
//

import Foundation
import SwiftUI

// 收件箱
struct CategoryInboxView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // Fetch all inbox tasks
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isDone == false AND isProject == false AND isGroup == false AND projectId == nil AND groupId == nil"),
        animation: .default
    )
    private var inboxItems: FetchedResults<TodoListItemCD>
    @State private var isEditing: Bool = false
    @State private var isEditingTask: Bool = false
    @State private var showDatePickerModal: Bool = false
    @State private var showDatePickerSwipeModalTask: TodoListItemCD?
    @State private var showDeleteAlert: Bool = false
    @State private var showNavbarTitle: Bool = false
    @State private var selectedTask: TodoListItemCD? = nil
    @FocusState private var editingTitleIsFocused: Bool
    @FocusState private var editingDescriptionIsFocused: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                // Track scroll position, show nav title when title is hidden behind navbar
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                            withAnimation {
                                showNavbarTitle = newValue < 44
                            }
                        }
                }
                .frame(height: 0) // Invisible, just for tracking scroll
                
                VStack {
                    HStack {
                        Image(systemName: "tray.fill")
                            .foregroundColor(Color.blue)
                            .font(.title)
                        Text("收件箱")
                            .font(.title).fontWeight(.bold)
                        Spacer()
                    }
                    
                    // Tasks
                    VStack {
                        ForEach(inboxItems) { task in
                            TodoListTask(task: task,
                                         isSelected: selectedTask?.id == task.id,
                                         onSelect: {
                                withAnimation {
                                    if selectedTask?.id != task.id {
                                        selectedTask = task
                                    }
                                }
                            },onSwipeRight: {
                                withAnimation {
                                    // Open the modal without expanding the task
                                    showDatePickerSwipeModalTask = task
                                    showDatePickerModal = true
                                }
                            },
                                         isEditingTask: $isEditingTask,
                                         showDatePickerModal: $showDatePickerModal)
                        }
                    }
                }.padding(.horizontal, 12)
                    .padding(.top, 60)
                    .navigationBarBackButtonHidden(true)
            }.padding(.top, 1)
            
            CategoryInboxNavigationBar(
                isEditing: isEditing,
                onBack: { self.presentationMode.wrappedValue.dismiss() },
                onMenu: { },
                onDone: {
                    withAnimation {
                        isEditingTask = false
                    }
                },
                onTitleTap: {},
                showTitle: showNavbarTitle
            )
            .frame(height: 44)
            .offset(y: isEditing || selectedTask != nil ? -120 : 0)
            .transition(.move(edge: .top))
            .animation(.easeInOut(duration: 0.3), value: isEditingTask)
            .zIndex(1)
            
            if inboxItems.count == 0 {
                VStack {
                    Spacer()
                    Image(systemName: "tray.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(hex: "#F3F3F3"))
                    Spacer()
                }
            }
            
            // Floating Action Button to add new task
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation{
                            isEditing = false
                        }
                        editingTitleIsFocused = false
                        editingDescriptionIsFocused = false
                        addNewTask()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }.padding()
            }.offset(y: selectedTask != nil ? 120 : 0)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: selectedTask)
            
            // Bottom buttons on edit task
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "arrow.right")
                        Text("移动")
                    }
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                    }
                    Button(action: {
                        withAnimation(.spring()) {
                            self.selectedTask = nil
                            self.isEditingTask = false
                        }
                    }) {
                        Image(systemName: "xmark.app")
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                    }
                }
                .padding()
                .frame(height: 48)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4.0)
            }
            .offset(y: selectedTask != nil && !showDatePickerModal ? 0 : 100 )
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: selectedTask)
            .animation(.easeInOut, value: showDatePickerModal)
            .zIndex(2.0)
            .ignoresSafeArea(.keyboard)
            
            // Finish Keyboard
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editingTitleIsFocused = false
                        editingDescriptionIsFocused = false
                        isEditing = false
                        isEditingTask = false
                    }
                }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .fontWeight(.bold)
                        .frame(height: 12)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .shadow(radius: 4)
                }
            }.offset(y: isEditing ? 0 : -120)
                .transition(.move(edge: .top))
                .zIndex(2.0)
            
            
            // Date Picker
            if (selectedTask != nil  && showDatePickerModal) {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        showDatePickerModal = false
                    }.zIndex(3.0)
                
                DatePicker(task: selectedTask!, showDatePickerModal: $showDatePickerModal)
                    .padding(.top, 90)
                    .padding(.horizontal, 20)
                    .zIndex(4.0)
            }
            
            // Modal logic
            if let showDatePickerSwipeModalTask = showDatePickerSwipeModalTask, showDatePickerModal {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        showDatePickerModal = false
                        self.showDatePickerSwipeModalTask = nil
                    }
                    .zIndex(3.0)
                
                DatePicker(task: showDatePickerSwipeModalTask, showDatePickerModal: $showDatePickerModal)
                    .padding(.top, 90)
                    .padding(.horizontal, 20)
                    .zIndex(4.0)
            }
            
            
        }.alert("删除任务",
                isPresented: $showDeleteAlert,
                actions: {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {deleteTask()}
        },
                message: {
            Text("删除待办事项")
        }
        )
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
    
    // Function to Add a New Task
    private func addNewTask() {
        do {
            let todo = TodoListItemCD(context: viewContext)
            todo.id = UUID()
            todo.isProject = false
            todo.isGroup = false
            todo.isDone = false
            todo.details = ""
            try viewContext.save()
        } catch {
            print("Error adding task: \(error)")
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // Function to Delete current Selected Task
    private func deleteTask() {
        guard let selectedTask = selectedTask else { return }
        viewContext.delete(selectedTask)
        do {
            try viewContext.save()
            self.selectedTask = nil
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct CategoryInboxNavigationBar: View {
    var isEditing: Bool
    var onBack: () -> Void
    var onMenu: () -> Void
    var onDone: () -> Void
    var onTitleTap: () -> Void
    var showTitle: Bool // Tracks whether to show the title
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                Spacer()
                if showTitle {
                    Image(systemName: "tray.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("收件箱")
                        .font(.headline)
                        .fontWeight(.bold)
                        .transition(.opacity)
                    Image(systemName: "chevron.down")
                        .font(.footnote)
                }
                Spacer()
                Menu {
                    Button("按标签筛选", action: { print("One") })
                    Button("选择", action: { print("Three") })
                    Button("粘贴", action: { print("Four") })
                    Button("共享", action: { print("Five") })
                } label: {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
    }
}

#Preview {
    CategoryInboxView()
}

