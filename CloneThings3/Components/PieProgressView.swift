//
//  PieProgressView.swift
//  CloneThings3
//
//  Created by George Li on 12/2/24.
//

import Foundation
import SwiftUI

// inspired: https://stackoverflow.com/questions/60258004/using-swiftui-how-do-i-animate-pie-progress-bar

struct PieProgress: View {
    var progress: Float // External input for progress (0.0 to 1.0)
    var radius: CGFloat = 100 // Default radius

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer Circle (Background)
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)

                // Progress Pie
                PieShape(progress: Double(self.progress))
                    .frame(width: (radius * 2) - 5, height: (radius * 2) - 5)
                    .foregroundColor(.blue)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)

        }
    }
}

struct PieShape: Shape {
    var progress: Double = 0.0
    private let startAngle: Double = (Double.pi) * 1.5
    private var endAngle: Double {
        get {
            return self.startAngle + Double.pi * 2 * self.progress
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arcCenter =  CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
        let radius = rect.size.width / 2
        path.move(to: arcCenter)
        path.addArc(center: arcCenter, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
        path.closeSubpath()
        return path
    }
}


#Preview {
    VStack {
        Circle()
            .stroke(Color.blue, lineWidth: 5)
            .overlay(
                PieShape(progress: Double(0.2))
                    .padding(4)
                    .foregroundColor(.blue)
            )
            .frame(maxWidth: .infinity)
            .animation(Animation.linear, value: 0.5) // << here !!
            .aspectRatio(contentMode: .fit)
        
        PieProgress(progress: 0.5, radius: 20)
    }
}
