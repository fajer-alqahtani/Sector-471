//
//  MainMenuUI.swift
//  Sector 471
//
//  Created by Oroub Alelewi on 09/02/2026.
//
//  DESCRIPTION (for the team):
//  MainMenuUI is the app’s main menu screen.
//  It shows a starry background (StarsBackdrop) and three primary navigation actions:
//    1) Start → launches the main story flow (EarthSpaceCrashFlow)
//    2) Accessibility → opens accessibility settings (AccessibilityScreen)
//    3) Chapters → opens the chapter selection menu (Chapters)
//
//  Design notes:
//  - The background stars are set to a FIXED opacity using `.constant(0.6)` to avoid
//    having multiple star layers / pulsing duplicates.
//  - Buttons use OmbreButtonStyle to match the game UI theme.
//  - The title ("Sector 417") is centered and shifted upward based on screen height.
//
import SwiftUI

struct MainMenuUI: View {

    @EnvironmentObject private var accessibility: AppAccessibilitySettings
    private var hexFillColor: Color { Color(hex: "#241D26") ?? .white }

    @State private var path = NavigationPath()
    @StateObject private var stars = StarsPulseViewModel(
        initialOpacity: 1.62,
        minOpacity: 1.55,
        maxOpacity: 0.70,
        pulseDuration: 1.6
    )

    private enum Route: Hashable {
        case flow
        case sitting
        case chapters
    }

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                let buttonWidth = min(proxy.size.width * 0.90, 530)

                ZStack {
                    
                    StarsBackdrop(
                        size: proxy.size,
                        starsOpacity: $stars.opacity,
                        starsOffsetFactor: 0.0,          
                        pulseDuration: stars.pulseDuration
                    )
                    
                    
                    

                    
                    VStack(spacing: 30) {

                        VStack(spacing: 1) {
                            Text("Sector")
                            Text("417")
                        }
                        .appFixedFont(85, settings: accessibility)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                        VStack(spacing: 30) {

                            Button {
                                path.append(Route.flow)
                            } label: {
                                Text("Start")
                                    .appFixedFont(40, settings: accessibility)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(menuButtonStyle(cornerRadius: 8))
                            .frame(width: buttonWidth)

                            Button {
                                path.append(Route.sitting)
                            } label: {
                                Text("Settings")
                                    .appFixedFont(40, settings: accessibility)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(menuButtonStyle(cornerRadius: 10))
                            .frame(width: buttonWidth)

                            Button {
                                path.append(Route.chapters)
                            } label: {
                                Text("Chapters")
                                    .appFixedFont(40, settings: accessibility)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(menuButtonStyle(cornerRadius: 8))
                            .frame(width: buttonWidth)
                        }
                    }
                    .offset(y: -proxy.size.height * 0.05)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .flow:
                    EarthSpaceCrashFlow()
                        .navigationBarBackButtonHidden(true)

                case .sitting:
                    Sitting(onBack: { path.removeLast() })
                        .navigationBarBackButtonHidden(true)

                case .chapters:
                    Chapters()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    private func menuButtonStyle(cornerRadius: CGFloat) -> OmbreButtonStyle {
        OmbreButtonStyle(
            baseFill: hexFillColor,
            cornerRadius: cornerRadius,
            contentInsets: EdgeInsets(top: 20, leading: 180, bottom: 20, trailing: 180),
            starHeight: 60
        )
    }
}
