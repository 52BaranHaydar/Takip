//
//  TakipApp.swift
//  Takip
//
//  Created by Baran on 16.03.2026.
//

import SwiftUI
import CoreData

@main
struct TakipApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
