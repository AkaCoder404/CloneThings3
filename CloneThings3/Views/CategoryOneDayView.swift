//
//  CategoryOneDayView.swift
//  CloneThings3
//
//  Created by George Li on 12/19/24.
//

import Foundation
import SwiftUI

//某天
struct CategoryOneDayView : View {
    var body: some View {
        HStack {
            Image(systemName: "archivebox")
                .foregroundColor(Color.orange)
            Text("某天")
        }
    }
}

#Preview {
    CategoryOneDayView()
}

