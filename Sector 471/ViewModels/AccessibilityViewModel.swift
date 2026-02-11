//
//  AccessibilityViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class AccessibilityViewModel: ObservableObject {

 
    let stars: StarsPulseViewModel

    private let accessibility: AppAccessibilitySettings
    private var cancellables = Set<AnyCancellable>()

    let baseFill: Color = Color(hex: "#241D26") ?? .white
    let toggleTint: Color = Color(hex: "#B57AD9") ?? .purple

    init(accessibility: AppAccessibilitySettings) {
        self.accessibility = accessibility
        self.stars = StarsPulseViewModel()

       
        stars.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var fontStyle: AppFontStyle {
        get { accessibility.fontStyle }
        set { accessibility.fontStyle = newValue }
    }

    var voiceOverOn: Bool {
        get { accessibility.voiceOverOn }
        set { accessibility.voiceOverOn = newValue }
    }

    func setFontStyle(_ style: AppFontStyle) {
        accessibility.fontStyle = style
    }

    func voiceOverRowOffsetY(_ h: CGFloat) -> CGFloat { 0 } 

    func start() {
        stars.startPulse()
    }
}
