//
//  SearchButtonToModal.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

struct SearchButtonToModal: View {
    // State variables to manage modal presentation
    @State private var showModal = false
    @Namespace private var animationNamespace
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    // Your existing content can go here
                    VStack {
                        Spacer()
                        // Search Button
                        Button(action: {
                            withAnimation(.spring()) {
                                showModal = true
                                isFocused = true
                            }
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.primary)
                                Text("快速查找")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(hex: "#F3F3F3"))
                            .cornerRadius(8.0)
                            .matchedGeometryEffect(id: "searchBar", in: animationNamespace)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        Spacer()
                    }
                }
                .disabled(showModal) // Disable interaction with ScrollView when modal is active
                
                if showModal {
                    // Overlay for Modal
                    VStack {
                        // Search Bar with Cancel Button
                        Spacer()
                        VStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                
                                TextField("搜索...", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.primary)
                                    .focused($isFocused)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.spring()) {
                                        showModal = false
                                        searchText = ""
                                    }
                                }) {
                                    Text("取消")
                                        .foregroundColor(.blue)
                                }
                            }.padding(.top, 10)
                                .padding(.bottom, 20)
                            
                            VStack(alignment: .leading) {
                                Text("结果2")
                                Text("结果2")
                                Text("结果2")
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack {
                                Text("搜索结果将显示在这里")
                                    .foregroundColor(.gray)
                            }.padding()
                    
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#F3F3F3"))
                        .cornerRadius(8.0)
                        .matchedGeometryEffect(id: "searchBar", in: animationNamespace)
                        .padding(.top, 50)
                        Spacer()
                    }
                    .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showModal = false
                            searchText = ""
                            isFocused = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SearchButtonToModal()
}
