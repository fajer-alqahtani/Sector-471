//
//  AccessibilityView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  AccessibilityView is the main UI screen where the player can change accessibility options.
//  It supports:
//  - Switching the app font style (Pixel vs OpenDyslexic).
//  - Toggling a custom "VoiceOver mode" setting.
//  - Showing a themed star background that gently pulses (opacity animation).
//  - Providing a back button that either calls a custom `onBack` callback or dismisses
//    via the NavigationStack environment.
//
//  Architecture:
//  - AppAccessibilitySettings (global) is injected from outside and used for the font system.
//  - AccessibilityViewModel (vm) owns UI styling colors + the stars pulse view model,
//    and provides helpers to update the global settings.
//

import SwiftUI

struct AccessibilityView: View {

    // Used when we want to dismiss the screen normally (NavigationStack back).
    @Environment(\.dismiss) private var dismiss

    // Global accessibility settings passed in from the parent (environment object in AccessibilityScreen).
    // We keep it as a stored property so we can pass it into font helpers and components.
    private let accessibility: AppAccessibilitySettings

    // Optional custom back action (used when this view is shown outside normal navigation).
    var onBack: (() -> Void)? = nil

    // ViewModel that manages star pulsing + exposes theme colors + proxies settings changes.
    @StateObject private var vm: AccessibilityViewModel

    /// Custom init is needed because we create a StateObject with a dependency (accessibility).
    init(accessibility: AppAccessibilitySettings, onBack: (() -> Void)? = nil) {
        self.accessibility = accessibility
        self.onBack = onBack
        _vm = StateObject(wrappedValue: AccessibilityViewModel(accessibility: accessibility))
    }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height // used to position the title stack

            ZStack(alignment: .topLeading) {

                // ===== Background stars (pulsing opacity) =====
                // StarsBackdrop expects a Binding<Double> for opacity.
                // vm.stars.opacity is @Published, so we bridge it into a Binding manually.
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: Binding(
                        get: { vm.stars.opacity },
                        set: { vm.stars.opacity = $0 }
                    ),
                    starsOffsetFactor: 0.35,
                    pulseDuration: vm.stars.pulseDuration
                )

                // ===== Back button =====
                // If the parent provided onBack, use it (custom navigation).
                // Otherwise, use the standard dismiss() from SwiftUI.
                Button {
                    if let onBack { onBack() } else { dismiss() }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .font(.system(size: 22, weight: .semibold))
                        .padding(12)
                        .background(.black.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.leading, 16)
                .padding(.top, 12)
                .zIndex(999) // ensure back button stays above everything

                // ===== Main controls =====
                VStack(spacing: 30) {

                    // Font style selection buttons.
                    fontButton(title: "Default font", style: .pixel, cornerRadius: 8)
                    fontButton(title: "OpenDyslexic", style: .dyslexic, cornerRadius: 10)

                    // VoiceOver toggle row (custom styled row).
                    OmbreToggleRow(
                        title: "VoiceOver",
                        isOn: Binding(get: { vm.voiceOverOn }, set: { vm.voiceOverOn = $0 }),
                        baseFill: vm.baseFill,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 160),
                        starHeight: 50,
                        toggleTint: vm.toggleTint,
                        toggleOffsetX: 140,     // fine-tune toggle alignment without moving text/icon
                        settings: accessibility, // font style source
                        fontSize: 40
                    )
                    // Allows fine-tuning vertical placement from the ViewModel.
                    .offset(y: vm.voiceOverRowOffsetY(0))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ===== Screen title =====
                VStack(spacing: 10) {
                    Text("Accessibility")
                    Image(systemName: "accessibility")
                        .font(.system(size: 60))
                }
                .appFixedFont(85, settings: accessibility)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30) // places title higher on the screen
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        // Start the stars pulsing when the view appears.
        .onAppear { vm.start() }
    }

    /// Builds one of the font style buttons.
    /// - Highlights the currently selected font by drawing a stroke around the button.
    private func fontButton(title: String, style: AppFontStyle, cornerRadius: CGFloat) -> some View {
        Button(title) {
            // Update global font style setting via ViewModel.
            vm.setFontStyle(style)
        }
        .appFixedFont(40, settings: accessibility)
        .foregroundStyle(.white)
        .buttonStyle(
            OmbreButtonStyle(
                baseFill: vm.baseFill,
                cornerRadius: cornerRadius,
                contentInsets: EdgeInsets(top: 20, leading: 115, bottom: 20, trailing: 115),
                starHeight: 50
            )
        )
        // Stroke appears only for the active selection.
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    Color.white.opacity(accessibility.fontStyle == style ? 0.9 : 0.0),
                    lineWidth: 2
                )
        )
    }
}
