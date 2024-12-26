//
//  CategoryPlanView.swift
//  CloneThings3
//
//  Created by George Li on 12/19/24.
//

import Foundation
import SwiftUI

// 计划
struct CategoryPlanView: View {
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(Color.red)
            Text("计划")
        }
    }
}

#Preview {
    CategoryPlanView()
}
