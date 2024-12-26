//
//  RandomView.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

struct PressableBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false

    var body: some View {
        Rectangle()
            .fill(isPressed ? (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)) : Color.clear)
            .animation(.easeInOut(duration: 0.2), value: isPressed) // Smooth animation
            .contentShape(Rectangle())
            .onTapGesture {
                isPressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
    }
}
