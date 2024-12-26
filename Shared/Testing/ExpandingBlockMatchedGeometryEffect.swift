//
//  ExpandingBlockMatchedGeometryEffect.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

// inspired: https://stackoverflow.com/questions/64581837/how-to-properly-use-matchedgeometry

struct ExpandingBlockMatchedGeometryEffect: View {
    @State var details = false
    @Namespace var animation
    
    var body: some View {
        ZStack {
            HStack {
                if !details {
                    Rectangle()
                        .matchedGeometryEffect(id: "id1", in: animation)
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            details.toggle()
                        }
                }
                Spacer()
            }.animation(.default, value: details)
            
            if details {
                AnotherView(details: $details, animation: animation)
            }
        }.animation(.default, value: details)
    }
}


struct AnotherView: View {
    @Binding var details: Bool
    var animation: Namespace.ID
    
    var body: some View {
        ZStack {
            Color.red
            
            Rectangle()
                .matchedGeometryEffect(id: "id1", in: animation)
                .frame(width: 300, height: 300)
                .onTapGesture {
                    details.toggle()
                }
        }
    }
}

#Preview {
    ExpandingBlockMatchedGeometryEffect()
}
