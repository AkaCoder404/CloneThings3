//
//  TodoListItem.swift
//  CloneThings3
//
//  Created by George Li on 12/1/24.
//

import Foundation
import SwiftUI

enum Tag : String {
    case daily = "Daily" // 日常
    case family = "Family" // 家庭
    case work = "Work" // 办公
    case important = "Important" // 重要
    case pending = "Pending" // 待定
}

enum DefaultAreas : String {
    case inbox = "Inbox" // 收件箱
    case today = "Today" // 今天
    case plan = "Plan" // 计划
    case whenever = "Whenever" // 随时
    case someday = "Some Day" // 某天
    case journal = "Journal" // 日常
}

// 新建区域 Area
// 新建项目 Project
// 新建待办事项 Todo
/// What the entity should look like
struct TodoListItemModal {
    let id: String
    let title: String
    let details: String
    let isProject: Bool     // a todo
    let isGroup: Bool       // a project can be part of group
    let parentId : String   // a todo list item can be a subtask
    let projectId : String  // a todo can be part of a project
    let groupId: String     // a project can be part of a group
//    let tag : [String]      // a todo list item can have multiple tags
    let isDone : Bool
    let dueDate: Date
    let notificationDate: Date
    let deadlineDate: Date
}
