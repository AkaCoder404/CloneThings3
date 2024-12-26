//
//  DatePicker.swift
//  CloneThings3
//
//  Created by George Li on 12/23/24.
//

import Foundation
import SwiftUI

struct DatePicker : View {
    @ObservedObject var task : TodoListItemCD
    @State private var editedSearch : String = ""
    @FocusState private var isSearchFocused : Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showDatePickerModal : Bool // Close the modal
    
    var body : some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Text("时间？")
                Spacer()
                Button("取消") {
                    showDatePickerModal = false
                }
            }.padding(.bottom, 10)
            
            // Search on pull down
            //            VStack {
            //                Button(action: {
            //                    isSearchFocused = true
            //                } ) {
            //                    HStack {
            //                        Image(systemName: "magnifyingglass")
            //                        if !isSearchFocused {
            //                            Text("搜索")
            //                        } else {
            //                            TextField("搜索", text: $editedSearch)
            //                                .focused($isSearchFocused)
            //                            Spacer()
            //                        }
            //                    }.frame(maxWidth: .infinity)
            //                        .padding(.vertical, 4)
            //                        .background(Color(UIColor.tertiarySystemBackground))
            //                        .cornerRadius(4.0)
            //                }
            //            }.padding(.bottom, 10)
            
            VStack(spacing: 10) {
                Button(action: { setToday() }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 20)
                            .padding(.horizontal, 5)
                        Text("今天").foregroundColor(.primary)
                        Spacer()
                        if task.dueDate != nil && isTodayMorning(task.dueDate!) {
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 5)
                        }
                    }
                }
                
                Button(action: { setTonight() }) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.teal)
                            .frame(width: 20)
                            .padding(.horizontal, 5)
                        Text("晚上").foregroundColor(.primary)
                        Spacer()
                        if task.dueDate != nil && isTodayTonight(task.dueDate!) {
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 5)
                        }
                    }
                }
            }
            
            // Calendar
            CalendarView { selectedDate in
                task.dueDate = selectedDate
                saveContext()
                showDatePickerModal = false
            }
            
            // 某天
            Button(action: {}) {
                HStack {
                    Image(systemName: "archivebox.fill")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                        .padding(.horizontal, 5)
                    Text("某天").foregroundColor(.primary)
                    Spacer()
//                    Image(systemName: "checkmark")
//                        .padding(.horizontal, 5)
                }
            }
            
            // 添加提醒 with Time Picker
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                        .frame(width: 20)
                        .padding(.horizontal, 5)
                    Text("添加提醒").foregroundColor(.primary)
                    Spacer()
                }
            }
            
            // 清除
            if task.dueDate != nil {
                VStack {
                    Button(action: {
                        task.dueDate = nil
                        saveContext()
                        showDatePickerModal = false
                    }) {
                        HStack {
                            Text("清除")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.primary)
                                .background(.red)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func setToday() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 0 // Set time to 0 AM
        task.dueDate = Calendar.current.date(from: components)
        saveContext()
        showDatePickerModal = false
    }
    
    private func setTonight() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 18 // Set time to 6 PM
        task.dueDate = Calendar.current.date(from: components)
        saveContext()
        showDatePickerModal = false
    }
    
    private func isToday() {
        // Check if the due date is set morning of today (or past)
    }
}

struct DayInfo: Identifiable {
    let id = UUID()
    let date: Date?
    let displayDay: String
    let isToday: Bool
}

class CalendarViewModel: ObservableObject {
    @Published var days: [DayInfo] = []
    let calendar = Calendar.current
    var currentDate = Date()

    init() {
        generateDaysInMonth(for: currentDate)
    }

    func generateDaysInMonth(for date: Date) {
        days = []

        // Get first day of the month
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        
        // Get "today" to compare
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = calendar.date(from: todayComponents)!

        // Number of days in the month
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numDays = range.count

        // Day of week for the first of the month
        let weekday = calendar.component(.weekday, from: startOfMonth)

        // Fill in blank days
        for _ in 1..<weekday {
            days.append(DayInfo(date: nil, displayDay: "", isToday: false))
        }

        // Add days of the month
        for day in 1...numDays {
            if let exactDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let isToday = calendar.isDate(exactDate, inSameDayAs: today)
                days.append(DayInfo(date: exactDate, displayDay: "\(day)", isToday: isToday))
            }
        }
    }

    func nextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = nextMonth
            generateDaysInMonth(for: currentDate)
        }
    }
    
    func previousMonth() {
        if let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = prevMonth
            generateDaysInMonth(for: currentDate)
        }
    }
}

struct CalendarView: View {
    @StateObject var viewModel = CalendarViewModel()
    
    /// A closure to notify the parent view when a date is tapped.
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack {
            // Display month and year
            HStack {
                Button(action: viewModel.previousMonth) {
                    Image(systemName: "chevron.left").foregroundColor(.primary)
                }
                Text("\(viewModel.currentDate, formatter: monthYearFormatter)")
                    .font(.headline)
                    .padding()
                Button(action: viewModel.nextMonth) {
                    Image(systemName: "chevron.right").foregroundColor(.primary)
                }
            }

            // Days of the week
            HStack(spacing: 0) {
                ForEach(["周日", "周一", "周二", "周三", "周四", "周五", "周六"], id: \.self) { day in
                    Text(day)
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 1)
                }
            }

            // Days in the month
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.days) { dayInfo in
                    if dayInfo.displayDay.isEmpty {
                        // Empty cell
                        Text("")
                            .frame(height: 35)
                    } else {
                        Button(action: {
                            if let validDate = dayInfo.date {
                                onDateSelected(validDate)
                            }
                        }) {
                            Text(dayInfo.isToday ? "" : dayInfo.displayDay)
                                .foregroundColor(.primary)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                                .background(
                                    dayInfo.isToday
                                    ? Image(systemName: "star.fill").foregroundColor(.primary)                                       : nil
                                )
                        }
                    }
                }
            }
        }
    }

    var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY年 M月"
        return formatter
    }
}


#Preview {
    let singleItem = PersistenceController.createSinglePreviewItem()
    let context = PersistenceController.previewTodoListItems.container.viewContext
    let showDatePickerModal = Binding.constant(false)
    return DatePicker(task: singleItem, showDatePickerModal: showDatePickerModal)
        .environment(\.managedObjectContext, context)
}
