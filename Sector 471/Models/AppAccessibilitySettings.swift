
//
//  AppAccessibilitySettings.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  This file defines a single source of truth for accessibility-related preferences used across the app.
//  It stores user choices (font style + voiceOver toggle) using AppStorage so they persist between launches.
//  The class manually triggers objectWillChange so SwiftUI updates immediately when these settings change,
//  even though the stored values are wrapped in @AppStorage (which isn’t a normal @Published property).
//

import SwiftUI
import Combine

/// Global accessibility settings shared through the app using
/// Conforms to ObservableObject so SwiftUI can refresh views when values change.
final class AppAccessibilitySettings: ObservableObject {

    // We manually manage updates instead of using @Published because the actual storage is @AppStorage.
    // When we update stored values, we call `objectWillChange.send()` to force SwiftUI to re-render views.
    let objectWillChange = ObservableObjectPublisher()

    // Persisted font style choice (stored as String rawValue in UserDefaults via AppStorage).
    @AppStorage(SettingsKeys.fontStyle)
    private var storedFontStyle: String = AppFontStyle.pixel.rawValue

    // Persisted "voiceOver" preference (stored as Bool in UserDefaults via AppStorage).
    @AppStorage(SettingsKeys.voiceOver)
    private var storedVoiceOver: Bool = false

    /// Current font style the UI should use.
    /// - Reads from `storedFontStyle` and converts it to `AppFontStyle`.
    /// - If the stored value is invalid/missing, defaults to `.pixel`.
    /// - On change: notifies SwiftUI, then saves new rawValue.
    var fontStyle: AppFontStyle {
        get { AppFontStyle(rawValue: storedFontStyle) ?? .pixel }
        set {
            objectWillChange.send()          //  refresh views immediately
            storedFontStyle = newValue.rawValue //  persist choice
        }
    }

    /// Whether the app should behave in a "voiceOver-friendly" mode (your custom accessibility toggle).
    /// - On change: notifies SwiftUI, then persists the new value.
    var voiceOverOn: Bool {
        get { storedVoiceOver }
        set {
            objectWillChange.send()  //  refresh views immediately
            storedVoiceOver = newValue // persist choice
        }
    }
}
