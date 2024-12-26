//
//  CategoryAnyTimeView.swift
//  CloneThings3
//
//  Created by George Li on 12/19/24.
//

import Foundation
import SwiftUI

// 随时
struct CategoryAnyTimeView : View {
    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .foregroundColor(Color.green)
            Text("随时")
        }
    }
}

#Preview {
    CategoryAnyTimeView()
}

