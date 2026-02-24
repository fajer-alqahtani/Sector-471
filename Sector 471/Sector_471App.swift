//
//  Sector_471App.swift
//  Sector 471
//
//  Created by Fajer alQahtani on 16/08/1447 AH.
//

import SwiftUI

@main
struct Sector_471App: App {
    @StateObject private var accessibility = AppAccessibilitySettings()
    @StateObject private var scriptStore = ScriptStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessibility)
                .environmentObject(scriptStore)
        }
    }
}
