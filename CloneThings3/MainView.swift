//
//  MainView.swift
//  CloneThings3
//
//  Created by George Li on 12/1/24.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct TodoListCategoryModal: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let logo: String
    let logoColor: Color
    let destination: AnyView
}

struct MainView : View {
    // Core Data - get current manage object context
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch all projects
    @FetchRequest(
        sortDescriptors:  [NSSortDescriptor(keyPath: \TodoListItemCD.title, ascending:true)],
        predicate: NSPredicate(format: "isProject == %@", NSNumber(value: true)),
        animation: .default
    )
    private var todos: FetchedResults<TodoListItemCD>
    
    // Fetch all inbox tasks
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "isDone == false AND isProject == false AND isGroup == false AND projectId == nil AND groupId == nil"),
        animation: .default
    )
    private var inboxItems: FetchedResults<TodoListItemCD>
    
    // Fetch all todays tasks
    @FetchRequest(
        sortDescriptors: [],
        // "isDone == false" so we only see incomplete tasks
        // "isProject == false AND isGroup == false" means it's a simple task
        // "dueDate < %@", Calendar.startOfTomorrow means dueDate is before tomorrow
        predicate: NSPredicate(format:
                                "isDone == false AND isProject == false AND isGroup == false AND dueDate < %@",
                               Calendar.startOfTomorrow as NSDate
                              ),
        animation: .default
    )
    private var todaysItems: FetchedResults<TodoListItemCD>
    
    @State private var showAlert = false
    @State private var showSettingsModal = false
    @State private var showNewTaskModal = false
    @State private var showAddNewModal = false
    @State private var showSearchModal = false
    
    private var todoListCategories: [TodoListCategoryModal] {[
        TodoListCategoryModal(title: "收件箱",
                              count: inboxItems.count,
                              logo: "tray.fill",
                              logoColor: Color.blue,
                              destination: AnyView(CategoryInboxView())),
        TodoListCategoryModal(title: "今天",
                              count: todaysItems.count,
                              logo: "star.fill",
                              logoColor: Color.yellow,
                              destination: AnyView(CategoryTodaysView())),
        TodoListCategoryModal(title: "计划",
                              count: 0,
                              logo: "calendar",
                              logoColor: Color.red,
                              destination: AnyView(CategoryPlanView())),
        TodoListCategoryModal(title: "随时",
                              count: 0,
                              logo: "square.stack.3d.up.fill",
                              logoColor: Color.green,
                              destination: AnyView(CategoryAnyTimeView())),
        TodoListCategoryModal(title: "某天",
                              count: 0,
                              logo: "archivebox",
                              logoColor: Color.orange,
                              destination: AnyView(CategoryOneDayView())),
        TodoListCategoryModal(title: "日志",
                              count: 0,
                              logo: "book.pages",
                              logoColor: Color.green,
                              destination: AnyView(CategoryLogView()))
    ]}
    
    // Create a new task
    @State private var newTask: TodoListItemCD?
    
    // Create a new project
    @State private var newlyCreatedProjectID: UUID? = nil
    
    // TodoListProject that's being dragged
    //    @State private var dragItem: TodoListItemCD?
    @State private var dragOffset: CGFloat = 0
    private let dragThreshold: CGFloat = 70  // how far user must drag
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        // Search Bar
                        Button(action: { withAnimation { showSearchModal = true }
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass").foregroundColor(.primary)
                                Text("快速查找").foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.secondarySystemBackground))
                            .background(dragOffset > dragThreshold
                                        ? Color.blue
                                        : Color(.secondarySystemBackground)
                            )
                            .cornerRadius(8.0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .opacity(showSearchModal ? 0 : 1)
                        
                        // The Arrow
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                            .opacity(Double(min(dragOffset, 100) / 100))  // fade in 0...1
                            .scaleEffect(1 + (dragOffset / 300)) // tiny scale effect
                            .padding(.bottom, 6)
                            .animation(.easeInOut, value: dragOffset)

                        // Categories
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(todoListCategories) { category in
                                TodoListCategory(
                                    title: category.title,
                                    count: category.count,
                                    logo: category.logo,
                                    logoColor: category.logoColor,
                                    destination: category.destination
                                )
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
                        Divider().padding(.vertical, 8)
                        
                        // Projects
                        VStack {
                            ForEach(todos) { project in
                                TodoListProject(project: project, newlyCreatedProjectID: $newlyCreatedProjectID)
                            }
                            .listStyle(.plain)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider().padding(.vertical, 8)
                        
                        // Spaces
                        VStack() {
                            HStack {
                                Image(systemName: "cube")
                                Text("New Group")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.padding(.leading, 10).padding(.trailing, 10)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider().padding(.vertical, 8)
                        
                        // Settings
                        VStack(alignment: .center) {
                            Button(action: { showSettingsModal = true },
                                   label: {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("设置")
                                }.foregroundColor(.primary)
                            })
                        }.frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }
                }.padding(.horizontal, 2)
                
                if showSettingsModal {
                    // Semi-transparent background
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            showSettingsModal = false
                        }.zIndex(3)
                    // Settings Modal with Navigation
                    SettingsModal(showModal: $showSettingsModal)
                        .zIndex(4)
                }
                
                // Search Modal
                if showSearchModal {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            showSearchModal = false
                        }.zIndex(3)
                    VStack {
                        SearchModal(context: viewContext, showModal: $showSearchModal)
                        Spacer()
                    }.zIndex(4)
                        .padding(.top, 15)
                }
                
                if showAddNewModal {
                    // Semi-transparent background
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            showAddNewModal = false
                        }.zIndex(3)
                    
                    VStack {
                        Spacer()
                        AddNewModal(createNewInboxTask: {
                            // 1) Create an in-memory item (unsaved yet)
                            let task = TodoListItemCD(context: viewContext)
                            task.id = UUID()
                            task.isProject = false
                            task.isGroup = false
                            task.isDone = false
                            // 2) Assign it to @State
                            newTask = task
                            showAddNewModal = false
                            showNewTaskModal = true
                            
                        }, createNewProject: {
                            do {
                                // attached to moc
                                let todo = TodoListItemCD(context: viewContext)
                                let newId = UUID()
                                todo.id = newId
                                todo.isProject = true
                                todo.isGroup = false
                                todo.isDone = false
                                todo.groupId = nil
                                todo.title = "新建项目 \(todos.count)"
                                try viewContext.save()
                                
                                withAnimation(.easeInOut){
                                    newlyCreatedProjectID = newId
                                }
                            } catch {
                                print("Erroring")
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                            showAddNewModal = false
                        }, createNewGroup: {
                            showAlert = true
                        })
                    }.zIndex(4.0)
                        .padding()
                }
                
                // Adding a new task
                if showNewTaskModal, let task = newTask {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            // If the user taps outside, we discard the new item:
                            viewContext.delete(task)   // remove from context so it won't linger
                            newTask = nil
                            showNewTaskModal = false
                        }
                        .zIndex(3)
                    
                    NewInboxTaskModal(
                        task: task,  // Pass the ObservedObject
                        closeButton: {
                            // User tapped the X button:
                            // If you want to discard changes:
                            viewContext.delete(task)
                            newTask = nil
                            showNewTaskModal = false
                        },
                        saveTask: {
                            // Actually commit the new item:
                            do {
                                try viewContext.save()
                            } catch {
                                print("Error saving new item: \(error)")
                            }
                            newTask = nil
                            showNewTaskModal = false
                        }
                    )
                    .zIndex(4)
                }
                
                // Finish Keyboard
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                newlyCreatedProjectID = nil
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
                    }.offset(y: newlyCreatedProjectID != nil ? 0 : -120)
                        .transition(.move(edge: .top))
                        .zIndex(2.0)
                    Spacer()
                }
                
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button (action: {
                            showAddNewModal = true
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
                        
                    }
                    .buttonStyle(.plain)
                    .padding()
                }.offset(y: newlyCreatedProjectID != nil ? 120 : 0)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: newlyCreatedProjectID)
            }
        }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("未完成"),
                    message: Text("此功能尚未实现。"),
                    dismissButton: .default(Text("确定"))
                )
            }
    }
    
    private func createNewProject () {}
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    // 应用程序CloneThings3的这歌版本不能与此版本的macOS配合使用
    //    MainView().environment(\.managedObjectContext, DataController().container.viewContext)
    MainView().environment(\.managedObjectContext, PersistenceController.previewTodoListItems.container.viewContext)
}
