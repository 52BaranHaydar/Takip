//
//  ContentView.swift
//  Takip
//
//  Created by Baran on 16.03.2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Ana Ekran", systemImage: "house") }
            
            ReportsView()
                .tabItem { Label("Raporlar", systemImage: "chart.bar") }
            
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
