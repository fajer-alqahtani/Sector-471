//
//  AccessibilityScreen.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
import SwiftUI

struct AccessibilityScreen: View {
    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    var onBack: (() -> Void)? = nil

    var body: some View {
        AccessibilityView(accessibility: accessibility, onBack: onBack)
    }
}
