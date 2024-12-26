//
//  ProjectView.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

struct ProjectView : View {
    @ObservedObject var project: TodoListItemCD
    @Environment(\.managedObjectContext) private var viewContext;
    @Environment(\.presentationMode) var presentationMode   // 1
    
    // FetchRequest to load tasks related to the project
    @FetchRequest private var tasks: FetchedResults<TodoListItemCD>
    
    // State variables for title editing
    @State private var isEditing: Bool = false
    @State private var isEditingTitle: Bool = false
    @State private var editedTitle: String = ""
    @State private var isEditingDescription: Bool = false
    @State private var editedDescription: String = ""
    @FocusState private var editingTitleIsFocused: Bool
    @FocusState private var editingDescriptionIsFocused: Bool
    
    // State variables for editing task
    @State private var isEditingTask = false
    
    // State variable for Delete Alert
    @State private var showDeleteAlert = false
    
    // State variable for Delete Project Alert
    @State private var showDeleteProjectAlert = false
    
    // Store variable to keep track of selected task
    @State private var selectedTaskID: UUID? = nil
    @State private var selectedTask: TodoListItemCD? = nil
    
    // State variable for modals
    @State private var showDatePickerModal = false
    
    // Task just when swipe right on TodoListTask is activated
    @State private var showDatePickerSwipeModalTask: TodoListItemCD?
    @State private var showMultipleSelectPickerSwipeModalTask: TodoListItemCD?
    
    // Computed property to calculate progress
    private var progress: Double { project.progress }
    
    // Custom initializer to configure the FetchRequest
    init(project: TodoListItemCD) {
        self.project = project
        self.editedTitle = project.title ?? ""
        self.editedDescription = project.details ?? ""
        
        if let projectId = project.id {
            self._tasks = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \TodoListItemCD.orderIndex, ascending: true)],
                predicate:  NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "projectId == %@", projectId as CVarArg),
                    NSPredicate(format: "isDone != %@", NSNumber(value: true))
                ]
                                                ),
                animation: .default
            )
        } else {
            // Handle the case where project.id is nil
            // For example right after deleting a project
            self._tasks = FetchRequest(
                sortDescriptors: [],
                predicate: NSPredicate(value: false), // No results
                animation: .default
            )
        }
    }
    
    // On Drag and Drop
    @State private var localTasks: [TodoListItemCD] = []
    @State private var fabOffset: CGSize = .zero
    @State private var allowReordering = true
    
    var body : some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top){
                    ScrollView {
                        VStack (alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Spacer().frame(height: 8)
                                    PieProgress(progress: Float(progress), radius:12)
                                        .frame(width: 24, height: 24)
                                    Spacer()
                                }
                                
                                TextField("新建项目", text: $editedTitle, axis:.vertical)
                                    .font(.title)
                                    .focused($editingTitleIsFocused)
                                    .onChange(of: editingTitleIsFocused) { oldValue, newValue in
                                        withAnimation {
                                            isEditing = editingTitleIsFocused || editingDescriptionIsFocused ? true : false
                                        }
                                    }
                                
                                if !editingTitleIsFocused {
                                    // TODO No .onMenuClosed modifier, create custom component
                                    Menu {
                                        Button("完成项目", action: { print("One") })
                                        Button("时间", action: { print("Two") })
                                        Button("添加标签", action: { print("Three") })
                                        Button("添加截止日期", action: { print("Four")})
                                        Button("重复", action: { print("Four")})
                                        Button("移动", action: { print("Five")})
                                        Button("复制", action: { print("Six")})
                                        Button("删除项目", action: { showDeleteProjectAlert = true } )
                                        Button("共享", action: { print("Eight")})
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(.gray))
                                            .padding()
                                            .contentShape(Rectangle())
                                            .frame(height:32)
                                    }
                                }
                            }
                            
                            // TODO TextEditor has some padding?
                            VStack {
                                TextField("新", text: $editedDescription, axis: .vertical)
                                    .frame(minHeight: 45)
                                    .focused($editingDescriptionIsFocused)
                                    .scrollContentBackground(.hidden)
                                    .onChange(of: editedDescription) { oldValue, newValue in
                                        project.details = newValue != "" ? newValue : "新建项目"
                                        saveContext()
                                    }
                                    .onChange(of: editingDescriptionIsFocused) { oldValue, newValue in
                                        withAnimation {
                                            isEditing = editingTitleIsFocused || editingDescriptionIsFocused ? true : false
                                        }
                                    }
                            }
                            
                            // For each todo list task
                            VStack  {
                                ReorderableForEach($localTasks, allowReordering: $allowReordering) { item, isDragged in
                                    TodoListTask(
                                        task: item,
                                        isSelected: selectedTask?.id == item.id,
                                        onSelect: {
                                            withAnimation {
                                                if selectedTask?.id != item.id {
                                                    selectedTask = item // expand task
                                                }
                                            }
                                        },
                                        onSwipeRight: {
                                            withAnimation {
                                                // Open the modal without expanding the task
                                                showDatePickerSwipeModalTask = item
                                                showDatePickerModal = true
                                            }
                                        },
                                        isEditingTask: $isEditingTask,
                                        showDatePickerModal: $showDatePickerModal
                                    )
                                    .padding(.vertical, 1)
                                    .scaleEffect(selectedTask?.id == item.id ? 1.05 : 1.0)
                                    .scaleEffect(isDragged ? 1.0 : 1.0)
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 10)
                            
                            VStack { Text("显示\(project.completedTasks)个录入项").font(.footnote) }.padding(.vertical, 10)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 60)
                        .navigationBarBackButtonHidden(true)
                    }.padding(.top, 1)
                    
                    
                    // Custom Navigation Bar
                    CustomNavigationBar(
                        isEditing: isEditing,
                        projectTitle: project.title ?? "No Title",
                        onBack: { self.presentationMode.wrappedValue.dismiss() },
                        onMenu: { },
                        onDone: {
                            withAnimation {
                                isEditingTitle = false
                            }
                        },
                        onTitleTap: {}
                    )
                    .frame(height: 44)
                    .offset(y: isEditing || selectedTask != nil ? -120 : 0)
                    .transition(.move(edge: .top))
                    .animation(.easeInOut(duration: 0.3), value: isEditingTitle)
                    .zIndex(1)
                    
                    // TODO Floating Action Button Draggable
                    //                    Circle()
                    //                        .fill(Color.blue)
                    //                        .overlay(
                    //                            Image(systemName: "plus")
                    //                                .resizable()
                    //                                .frame(width: 24, height: 24)
                    //                                .foregroundColor(.white)
                    //                        )
                    //                        .frame(width: 56, height: 56)
                    //                        .offset(x: fabOffset.width, y: fabOffset.height)
                    //                        .gesture(
                    //                            DragGesture()
                    //                                .onChanged { value in fabOffset = value.translation }
                    //                                .onEnded { value in
                    //                                    // If you want the FAB to "snap" back to a corner, do it here
                    //                                    // or store the final offset for a custom location
                    //                                    fabOffset = .zero
                    //                                }
                    //                        )
                    //                        .onTapGesture { addNewTask() }
                    
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
                    }
                    .offset(y: selectedTask != nil  || isEditing  ? 120 : 0)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: selectedTask)
                    .ignoresSafeArea(.keyboard)
                    
                    // Confirm editing project title/description
                    HStack {
                        Spacer()
                        Button(action: {
                            project.title = editedTitle != "" ? editedTitle : "新建项目";
                            project.details = editedDescription != "" ? editedDescription : "备注";
                            saveContext()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                editingTitleIsFocused = false
                                editingDescriptionIsFocused = false
                                isEditing = false
                                isEditingDescription = false
                                isEditingTitle = false
                            }
                        }) {
                            Text("完成")
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
                    
                    // Finish Keyboard
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                editingTitleIsFocused = false
                                editingDescriptionIsFocused = false
                                isEditing = false
                                isEditingDescription = false
                                isEditingTitle = false
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
                    }.offset(y: isEditingTask ? 0 : -120)
                        .transition(.move(edge: .top))
                        .zIndex(2.0)
                    
                    
                    // Bottom Button
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
                }
            }
        }
        /// Inspired: https://stackoverflow.com/questions/58069516/how-can-i-have-two-alerts-on-one-view-in-swiftui
        .alert("删除任务",
               isPresented: $showDeleteAlert,
               actions: {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {deleteTask()}
        },
               message: { Text("删除待办事项") }
        ).alert("确定要删除此项目吗？",
                isPresented: $showDeleteProjectAlert,
                actions:{
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {deleteProject()}
        },
                message: { Text("这将删除所有相关的任务。") }
        )
        // Drag and Drop
        .onAppear {
            // On appear, copy from fetchedTasks into localTasks
            localTasks = Array(tasks)
        }.onChange(of: tasks.map { $0 }) { _, newItems in
            // If the fetch results change externally, keep localTasks in sync
            localTasks = newItems
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
    
    // Function to Add a New Task
    private func addNewTask() {
        do {
            let todo = TodoListItemCD(context: viewContext)
            todo.id = UUID()
            todo.isProject = false
            todo.isGroup = false
            todo.isDone = false
            todo.projectId = project.id
            todo.details = ""
            todo.orderIndex = (tasks.last?.orderIndex ?? 0) + 1
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
    
    // Function to Delete current Project and its Tasks
    private func deleteProject() {
        for task in tasks {
            viewContext.delete(task)
        }
        viewContext.delete(project)
        saveContext()
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct CustomNavigationBar: View {
    var isEditing: Bool
    var projectTitle: String
    var onBack: () -> Void
    var onMenu: () -> Void
    var onDone: () -> Void
    var onTitleTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                Spacer()
                Menu {
                    Button("按标签筛选", action: { print("One") })
                    Button("新建标题", action: { print("Two") })
                    Button("选择", action: { print("Three") })
                    Button("粘贴", action: { print("Four")})
                    Button("共享", action: { print("Five")})
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
    let singleItem = PersistenceController.createSinglePreviewItem()
    //    let context = PersistenceController.preview.container.viewContext
    let context = PersistenceController.previewTodoListItems.container.viewContext
    return ProjectView(project: singleItem)
        .environment(\.managedObjectContext, context)
}

