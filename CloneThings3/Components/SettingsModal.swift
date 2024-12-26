//
//  SettingsModal.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

enum SettingsSection {
    case main
    case help
    case about
    case copyright
    // Add more sections as needed
}

enum TransitionDirection {
    case forward
    case backward
}

struct SettingsModal: View {
    @Binding var showModal: Bool
    @State private var currentSection: SettingsSection = .main
    @State private var transitionDirection: TransitionDirection = .forward
    
    private var navigationBackTitle: String {
        switch currentSection {
        case .main, .help, .about:
            return "设置"
        case .copyright:
            return "帮助"
        }
    }
    private var navigationCurrentTitle: String {
        switch currentSection {
        case .main:
            return "设置"
        case .help:
            return "帮助"
        case .about:
            return "关于"
        case .copyright:
            return "版权"
        }
    }
    
    var body: some View {
        VStack {
            // Header
            ZStack {
                HStack {
                    if currentSection != .main {
                        // Back Button
                        Button(action: {
                            // Set transitionDirection before the animation
                            transitionDirection = .backward
                            withAnimation(.easeInOut) {
                                navigateBack()
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text(navigationBackTitle)
                            }
                        }
                        .padding(.leading)
                    } else { Spacer() }
                    
                    Spacer()
                    
                    // "完成" Button
                    Button(action: {
                        withAnimation(.easeInOut) {
                            showModal = false
                        }
                    }) {
                        Text("完成").bold()
                    }
                    .padding(.trailing)
                }
                // Center Title
                Text(navigationCurrentTitle)
            }
            .padding(.top, 10)
            
            Divider()
            
            // Content Area with Transition
            ZStack {
                switch currentSection {
                case .main:
                    MainSettingsView(
                        onHelpTap: {
                            // Set transitionDirection before the animation
                            transitionDirection = .forward
                            withAnimation(.easeInOut) {
                                currentSection = .help
                            }
                        },
                        onAboutTap: {
                            transitionDirection = .forward
                            withAnimation(.easeInOut) {
                                currentSection = .about
                            }
                        }
                    )
                    .transition(transitionTransition())
                    
                case .help:
                    HelpView(
                        onNavigateToCopyright: {
                            // Set transitionDirection before the animation
                            transitionDirection = .forward
                            withAnimation(.easeInOut) {
                                currentSection = .copyright
                            }
                        }
                    )
                    .transition(transitionTransition())
                    
                case .copyright:
                    CopyrightView()
                        .transition(transitionTransition())
                    
                case .about:
                    AboutView()
                        .transition(transitionTransition())
                }
                // Add more sections here with case blocks
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 20)
        .padding(.horizontal, 20)
        .padding(.vertical, 80)
    }
    
    // Navigation Back Function
    private func navigateBack() {
        switch currentSection {
        case .copyright:
            currentSection = .help
        case .help:
            currentSection = .main
        case .about:
            currentSection = .main
        case .main:
            break
        }
    }
    
    // Define the transition based on direction
    private func transitionTransition() -> AnyTransition {
        return transitionDirection == .forward
        ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        : .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }
}

// Inspired: https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button
struct SettingsRowButton<LeadingContent: View, Label: View>: View {
    var action: () -> Void
    var leadingContent: () -> LeadingContent // Generic for leading view
    var label: () -> Label // Generic for label view
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                leadingContent() // Use the provided leading content
                label()
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
            .background(isPressed ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(4)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .onTapGesture {
            action()
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

struct MainSettingsView: View {
    var onHelpTap: () -> Void
    var onAboutTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SettingsRowButton(
                action: { /* Your action here */ },
                leadingContent: {
                    Image(systemName: "cloud.fill")
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                        .background(.secondary)
                        .cornerRadius(4)
                },
                label: {
                    Text("Things Cloud")
                }
            )
            
            SettingsRowButton( action: { /* Your action here */ },
                leadingContent: {
                    Image("reminders-app-icon")
                        .resizable()
                        .frame(width: 25, height: 25)
                },
                label: { Text("提醒事项收件箱") }
            )
            
            SettingsRowButton( action: {/* Your action here */},
                leadingContent: { Image("calendar-app-icon")
                        .resizable()
                        .frame(width: 25, height: 25)
                },
                label: { Text("日历事件") }
            )
            
            SettingsRowButton( action: {},
                leadingContent: {
                    Image("siri-app-icon")
                        .resizable()
                        .frame(width: 25, height: 25)
                },
                label: { Text("Siri") }
            )
            
            SettingsRowButton( action: {},
                leadingContent: {
                    Image(systemName: "textformat")
                        .frame(width:15, height: 15)
                        .padding(5)
                        .foregroundColor(Color.white)
                        .background(Color.secondary)
                        .cornerRadius(4)
                },
                label: { Text("外观") }
            )
            
            SettingsRowButton( action: {},
                leadingContent: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .padding(5)
                        .foregroundColor(Color.white)
                        .background(Color.secondary)
                        .cornerRadius(4)
                }, label: {Text("常规")}
            )
            
        
            Divider()
            
            SettingsRowButton( action: { onHelpTap() },
                leadingContent: {
                    Image(systemName: "questionmark.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.yellow)
                },
                label: { Text("帮助") }
            )
            
            SettingsRowButton( action: { },
                leadingContent: {
                    Image(systemName: "arrow.down.square.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                },
                label: { Text("倒入") }
            )
            
            SettingsRowButton( action: { onAboutTap() },
                leadingContent: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                },
                label: { Text("关于") }
            )
            
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                Text("获取 Things3 Clone for IPhone。")
                    .foregroundColor(.secondary)
                Spacer()
            }.padding()
        }
        .padding(.horizontal, 5)
    }
}

struct HelpView: View {
    var onNavigateToCopyright: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Help Content
            Text("帮助")
                .font(.title)
                .bold()
            
            Text("这里是帮助内容的详细信息。您可以在这里添加更多的帮助文本或指南。")
                .font(.body)
            
            // Additional Help Sections
            Button(action: {
                // Navigate to Copyright
                onNavigateToCopyright()
            }) {
                HStack {
                    Image(systemName: "doc.plaintext")
                        .foregroundColor(.blue)
                    Text("版权信息")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Example AboutView (You can implement similarly)
struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("things3-app-icon")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.vertical, 20)
            
            Text("Things3 Clone")
            Text("AkaCoder404")
            
            Spacer().frame(height: 30)
            
            Text("Build XXX")
            Text("iOS XXX")
            
            Spacer().frame(height: 50)
            
            Button(action: {}) {
                Text("拷贝设备信息")
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .background(Color(hex: "#ADD8E6"))
            .cornerRadius(8.0)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
    }
}


struct CopyrightView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Copyright Content
            Text("版权信息")
                .font(.title)
                .bold()
            
            Text("这里是版权信息的详细内容。您可以在这里添加更多的版权文本或声明。")
                .font(.body)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingsModal_Previews: PreviewProvider {
    static var previews: some View {
        SettingsModal(showModal: .constant(true))
    }
}
