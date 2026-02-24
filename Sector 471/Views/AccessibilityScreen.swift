//
//  AccessibilityScreen.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  AccessibilityScreen is a thin wrapper used for navigation.
//  It pulls the shared AppAccessibilitySettings from the environment and passes it into
//  AccessibilityView.
//  This keeps the "real" UI in AccessibilityView while making it easy to present this screen
//  from NavigationLink / Flow screens.
//  `onBack` is optional so this screen can work in different contexts:
//  - If provided, AccessibilityView can call it to go back (custom back behavior).
//  - If nil, the view can rely on the default navigation dismiss/back behavior.
//

import SwiftUI

struct AccessibilityScreen: View {

    // Shared global accessibility settings (font style + voiceOver toggle).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Optional callback for custom back navigation.
    var onBack: (() -> Void)? = nil

    var body: some View {
        // Pass the environment settings down to the actual screen implementation.
        AccessibilityView(accessibility: accessibility, onBack: onBack)
    }
}
