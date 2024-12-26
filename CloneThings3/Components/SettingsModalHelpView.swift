//
//  SettingsModalHelpView.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

struct SettingsModalHelpView: View {
        @Binding var showModal: Bool
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("帮助内容")
                        .font(.title2)
                        .bold()
    
                    Text("这里是帮助内容的详细信息。您可以在这里添加更多的帮助文本或指南。")
                        .font(.body)
                    
                    // Add more help sections as needed
                }
                .padding()
            }
            .navigationTitle("帮助")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        withAnimation {
                            showModal = false
                        }
                    }
                }
            }
        }
    }


struct SettingsModalHelpView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsModalHelpView(showModal: .constant(true))
    }
}
