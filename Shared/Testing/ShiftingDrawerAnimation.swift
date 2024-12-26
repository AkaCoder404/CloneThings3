//
//  ShiftingDrawerAnimation.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

struct ShiftingDrawerAnimation: View {
    @State private var isShowingMenu: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                Button(action: {
                    withAnimation { // here
                        isShowingMenu.toggle()
                    }
                }, label: {
                    Text("Button")
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
            }
            .offset(x: isShowingMenu ? 200 : 0)
            
            if isShowingMenu {
                Rectangle()
                    .frame(width: 200, alignment: .leading)
                    .transition( .move(edge: .leading))
            }
        }
    }
}


#Preview {
    ShiftingDrawerAnimation()
}
