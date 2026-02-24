//
//  AccessibilityViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  This ViewModel powers the Accessibility screen.
//  It does two main jobs:
//  1) Acts as a bridge between the UI and AppAccessibilitySettings (font style + voiceOver toggle),
//     so the screen can read/update global accessibility preferences.
//  2) Owns a StarsPulseViewModel for the animated star background on this screen.
//     Because StarsPulseViewModel is a separate ObservableObject, we forward its changes
//     into this ViewModel so the screen refreshes when star opacity changes.
//

import SwiftUI
import Combine

@MainActor
final class AccessibilityViewModel: ObservableObject {

    // Star background animation state (opacity pulsing).
    // The view reads this to control the StarsBackdrop opacity.
    let stars: StarsPulseViewModel

    // Reference to the shared/global accessibility settings stored in AppAccessibilitySettings.
    private let accessibility: AppAccessibilitySettings

    // Holds Combine subscriptions to keep them alive for the lifetime of this ViewModel.
    private var cancellables = Set<AnyCancellable>()

    // Theme colors used by the screen’s UI components.
    let baseFill: Color = Color(hex: "#241D26") ?? .white
    let toggleTint: Color = Color(hex: "#B57AD9") ?? .purple

    /// Creates the ViewModel using the shared AppAccessibilitySettings (injected from the view).
    /// Also creates a StarsPulseViewModel and forwards its updates to this ViewModel.
    init(accessibility: AppAccessibilitySettings) {
        self.accessibility = accessibility
        self.stars = StarsPulseViewModel()

        // StarsPulseViewModel is its own ObservableObject.
        // We forward its objectWillChange into this ViewModel so the UI updates smoothly
        // when the star opacity changes.
        stars.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    /// Current app font style (pixel or dyslexic).
    /// This is just a computed proxy to the global accessibility settings.
    var fontStyle: AppFontStyle {
        get { accessibility.fontStyle }
        set { accessibility.fontStyle = newValue }
    }

    /// Whether the app should be in your custom "voiceOver-friendly" mode.
    /// Also a proxy to the global accessibility settings.
    var voiceOverOn: Bool {
        get { accessibility.voiceOverOn }
        set { accessibility.voiceOverOn = newValue }
    }

    /// Convenience method to update the font style from button actions.
    func setFontStyle(_ style: AppFontStyle) {
        accessibility.fontStyle = style
    }

    /// Used to fine-tune the vertical position of the VoiceOver toggle row from the view.
    /// Currently returns 0 (no offset), but can be adjusted later if needed.
    func voiceOverRowOffsetY(_ h: CGFloat) -> CGFloat { 0 }

    /// Starts the animated star pulse for this screen (call onAppear).
    func start() {
        stars.startPulse()
    }
}
