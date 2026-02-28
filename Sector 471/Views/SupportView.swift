//
//  SupportView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 11/09/1447 AH.
//
//
//  DESCRIPTION (for the team):
//  SupportView is a Support & Info screen that matches the Sitting visual system:
//  - StarsBackdrop + StarsPulseViewModel pulsing background
//  - OmbreButtonStyle rows with locked sizing across fonts
//  - Top-left back button that calls onBack()
//  - Title at the top (like other menus)
//
//  Rows (placeholders for now):
//  - About (push/overlay later)
//  - Contact Us (link later)
//  - Rate our app (link later)
//  - Report a bug (link later)
//  - Credits (push/overlay later)
//  - Version label at the bottom
//

import SwiftUI

struct SupportView: View {

    // Callback used to close this screen and return to the previous screen.
    var onBack: () -> Void

    // Global accessibility settings (controls font style: pixel vs dyslexic).
    @EnvironmentObject private var accessibility: AppAccessibilitySettings

    // Star pulsing state used by StarsBackdrop (opacity changes over time).
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 0.6,
        minOpacity: 0.35,
        maxOpacity: 0.85,
        pulseDuration: 1.5
    )

    // Base fill color used for Ombre buttons (fallback to white if hex fails).
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    
    private let rowHeight: CGFloat = 82
    private let rowMaxWidth: CGFloat = 560

    
    private let versionText: String = "Version 1.0"

    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height

            ZStack(alignment: .topLeading) {

                // ===== Background stars =====
                StarsBackdrop(
                    size: proxy.size,
                    starsOpacity: $stars.opacity,
                    starsOffsetFactor: 0.35,
                    pulseDuration: stars.pulseDuration
                )

                // ===== Back button =====
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(20)
                        .background(.purple.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 162, style: .continuous))
                }
                .padding(.leading, 26)
                .padding(.top, 22)
                .zIndex(999)

                // ===== Rows =====
                VStack(spacing: 16) {

                    Button {} label: {
                        rowWithLeadingIcon(title: "About", leadingIcon: "sparkles", trailingIcon: "chevron.forward")
                    }
                    .supportRowStyle(accessibility: accessibility, style: menuRowStyle, rowMaxWidth: rowMaxWidth, rowHeight: rowHeight)

                    Button {  } label: {
                        rowWithLeadingIcon(title: "Contact Us", leadingIcon: "person.crop.circle", trailingIcon: "link")
                    }
                    .supportRowStyle(accessibility: accessibility, style: menuRowStyle, rowMaxWidth: rowMaxWidth, rowHeight: rowHeight)

                    Button {  } label: {
                        rowWithLeadingIcon(title: "Rate our app", leadingIcon: "heart", trailingIcon: "link")
                    }
                    .supportRowStyle(accessibility: accessibility, style: menuRowStyle, rowMaxWidth: rowMaxWidth, rowHeight: rowHeight)

                    Button {  } label: {
                        rowWithLeadingIcon(title: "Report a bug", leadingIcon: "ant", trailingIcon: "link")
                    }
                    .supportRowStyle(accessibility: accessibility, style: menuRowStyle, rowMaxWidth: rowMaxWidth, rowHeight: rowHeight)

                    Button {  } label: {
                        rowWithLeadingIcon(title: "Credits", leadingIcon: "asterisk.circle", trailingIcon: "chevron.forward")
                    }
                    .supportRowStyle(accessibility: accessibility, style: menuRowStyle, rowMaxWidth: rowMaxWidth, rowHeight: rowHeight)

                    
                    Button { } label: {
                        Text(versionText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .appFixedFont(40, settings: accessibility)
                    .buttonStyle(menuRowStyle)
                    .frame(maxWidth: rowMaxWidth)
                    .frame(height: rowHeight)
                    .disabled(true)
                    .padding(.top, 4)
                }
                .padding(.top, 230)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // ===== Title =====
                Text("Support & Info")
                    .appFixedFont(85, settings: accessibility)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(y: -h * 0.30)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .ignoresSafeArea()
        }
        .onAppear { stars.startPulse() }
    }

    // MARK: - Row builder 

    private func rowWithLeadingIcon(title: String, leadingIcon: String, trailingIcon: String) -> some View {
        HStack(spacing: 14) {

            Image(systemName: leadingIcon)
                .font(.system(size: 22, weight: .regular))
                .frame(width: 28, alignment: .leading)

            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: trailingIcon)
                .font(.system(size: 24))
                .imageScale(.large)
        }
        .foregroundStyle(.white)
    }

    // MARK: - Style

    private var menuRowStyle: OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: 8,
            contentInsets: EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24),
            starHeight: 50
        )
    }
}

// MARK: - Small helper to avoid repeating modifiers
private extension View {
    func supportRowStyle(
        accessibility: AppAccessibilitySettings,
        style: OmbreButtonStyle,
        rowMaxWidth: CGFloat,
        rowHeight: CGFloat
    ) -> some View {
        self
            .appFixedFont(40, settings: accessibility)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .buttonStyle(style)
            .frame(maxWidth: rowMaxWidth)
            .frame(height: rowHeight)
    }
}

