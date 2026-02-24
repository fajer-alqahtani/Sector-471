//
//  AccessibilityView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//

import SwiftUI

struct AccessibilityView: View {
    @Environment(\.dismiss) private var dismiss

    
    private let accessibility: AppAccessibilitySettings
    var onBack: (() -> Void)? = nil

    @StateObject private var vm: AccessibilityViewModel

    init(accessibility: AppAccessibilitySettings, onBack: (() -> Void)? = nil) {
        self.accessibility = accessibility
        self.onBack = onBack
        _vm = StateObject(wrappedValue: AccessibilityViewModel(accessibility: accessibility))
    }

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack(alignment: .topLeading) {

                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: Binding(
                        get: { vm.stars.opacity },
                        set: { vm.stars.opacity = $0 }
                    ),
                    starsOffsetFactor: 0.35,
                    pulseDuration: vm.stars.pulseDuration
                )

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
                .zIndex(999)

                VStack(spacing: 30) {

                    fontButton(title: "Default font", style: .pixel, cornerRadius: 8)
                    fontButton(title: "OpenDyslexic", style: .dyslexic, cornerRadius: 10)

                    OmbreToggleRow(
                        title: "VoiceOver",
                        isOn: Binding(get: { vm.voiceOverOn }, set: { vm.voiceOverOn = $0 }),
                        baseFill: vm.baseFill,
                        cornerRadius: 10,
                        contentInsets: EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 160),
                        starHeight: 50,
                        toggleTint: vm.toggleTint,
                        toggleOffsetX: 140,
                        settings: accessibility,
                        fontSize: 40
                    )
                    .offset(y: vm.voiceOverRowOffsetY(0))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 10) {
                    Text("Accessibility")
                    Image(systemName: "accessibility")
                        .font(.system(size: 60))
                }
                .appFixedFont(85, settings: accessibility)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .offset(y: -h * 0.30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear { vm.start() }
    }

    private func fontButton(title: String, style: AppFontStyle, cornerRadius: CGFloat) -> some View {
        Button(title) { vm.setFontStyle(style) }
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
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(accessibility.fontStyle == style ? 0.9 : 0.0), lineWidth: 2)
            )
    }
}
