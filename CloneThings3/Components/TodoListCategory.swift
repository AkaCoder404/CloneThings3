//
//  TodoListCategory.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

struct TodoListCategory : View {
    let title: String
    let count: Int
    let logo: String
    let logoColor: Color
    let destination: AnyView
    
    var body : some View {
        NavigationLink(destination: destination) {
            HStack(alignment:.firstTextBaseline) {
                Image(systemName: logo).foregroundColor(logoColor)
                Text(title).foregroundColor(.primary)
                Spacer()
                if count != 0 {
                    Text(String(count)).foregroundColor(.primary)
                }
            }.padding(.vertical, 5)
                .padding(.horizontal, 8)
        }
    }
}

#Preview {
    TodoListCategory(title: "收件箱", count: 5, logo: "tray.fill", logoColor: Color.blue, destination: AnyView(CategoryTodaysView()))
}
