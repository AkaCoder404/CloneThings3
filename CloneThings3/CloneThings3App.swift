//
//  CloneThings3App.swift
//  CloneThings3
//
//  Created by George Li on 12/1/24.
//

import SwiftUI

@main
struct CloneThings3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
