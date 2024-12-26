//
//  TextFieldDynamicWidth.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

// inspiration: https://github.com/joehinkle11/TextFieldDynamicWidth

struct TextFieldDynamicWidth: View {
    let title: String
    @Binding var text: String
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    @State private var textRect = CGRect()
    
    var body: some View {
        ZStack {
            Text(text == "" ? title : text).background(GlobalGeometryGetter(rect: $textRect))
                .layoutPriority(1)
                .opacity(0)
            HStack {
                TextField(title, text: $text, axis: .vertical)
                    .frame(width: textRect.width)
                    .onChange(of: text) {
                        // TODO
                        onEditingChanged(true)
                    }
                Text("Hello")
            }
        }
    }
}

//
//  GlobalGeometryGetter
//
// source: https://stackoverflow.com/a/56729880/3902590
//
struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}


struct TextFieldDynamicWidth_Previews: PreviewProvider {
    @State static var editingText: String = ""
    
    static var previews: some View {
        HStack(spacing: 0) {
            TextFieldDynamicWidth(title: "Type something here!", text: $editingText) { editingChange in
                // logic
            } onCommit: {
                // logic
            }.font(.title).multilineTextAlignment(.leading)
            Text("This text will appear immediately to the right of the text field")
        }
    }
}
