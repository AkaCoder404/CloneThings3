//
//  MultipleChoiceMatchedGeometryEffect.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI
struct MultipleChoiceMatchedGeometryEffect: View {
    @Namespace private var namespace
    @State private var fillingBlank = false
    @State private var answer = 0

    private func buttonForAnswer(num: Int) -> some View {
        Button("Answer \(num)") {
            answer = num
            withAnimation {
                fillingBlank = true
            }
        }
        .buttonStyle(.borderedProminent)
        .matchedGeometryEffect(
            id: num,
            in: namespace,
            isSource: answer == num && !fillingBlank
        )
        .background {

            // This is the text that floats to the blank space
            Text("Answer \(num)")
                .foregroundColor(.primary)
                .matchedGeometryEffect(
                    id: answer == num && fillingBlank ? 0 : num,
                    in: namespace,
                    properties: .position,
                    isSource: false
                )
        }
    }

    var body: some View {
        VStack(spacing: 30) {

            // Question section
            HStack {
                Text("(question part 1)")
                Text("blank space")
                    .foregroundColor(.secondary.opacity(0.5))
                    .opacity(fillingBlank ? 0 : 1)
                    .background(alignment: .bottom) {
                        VStack {
                            Divider().background(.primary)
                        }
                    }
                    .matchedGeometryEffect(
                        id: 0,
                        in: namespace,
                        isSource: fillingBlank
                    )
                Text("(question part 2)")
            }
            // Answer section
            Text("Every answer is correct, please pick one!")
                .padding(.top, 50)
            VStack {
                HStack(spacing: 20) {

                    // The buttons for the answers
                    ForEach(1...3, id: \.self) { num in
                        buttonForAnswer(num: num)
                    }
                }
                .overlay {

                    // The reset button
                    if fillingBlank {
                        HStack {
                            Button("Reset") {
                                withAnimation {
                                    fillingBlank = false
                                }
                            }
                            .buttonStyle(.borderedProminent )
                            .tint(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                    }
                }
            }
        }
    }
}


#Preview {
    MultipleChoiceMatchedGeometryEffect()
}
