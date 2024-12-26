//
//  CategoryLogView.swift
//  CloneThings3
//
//  Created by George Li on 12/19/24.
//

import Foundation
import SwiftUI

// 日志
struct CategoryLogView : View {
    var body: some View {
        HStack {
            Image(systemName: "book.pages")
                .foregroundColor(Color.green)
            Text("日志")
        }
    }
}

#Preview {
    CategoryLogView()
}


