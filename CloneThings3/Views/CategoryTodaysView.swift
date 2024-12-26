//
//  CategoryTodaysView.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

// 今天
struct CategoryTodaysView : View {
    
    @Environment(\.managedObjectContext) private var viewContext;
    
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(Color.yellow)
            Text("今天")     
        }
    }
    
    
}

#Preview {
    CategoryTodaysView()
}
