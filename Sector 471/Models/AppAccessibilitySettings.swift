
//  AppAccessibilitySettings.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//

import SwiftUI
import Combine

final class AppAccessibilitySettings: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    @AppStorage(SettingsKeys.fontStyle)
    private var storedFontStyle: String = AppFontStyle.pixel.rawValue

    @AppStorage(SettingsKeys.voiceOver)
    private var storedVoiceOver: Bool = false

    var fontStyle: AppFontStyle {
        get { AppFontStyle(rawValue: storedFontStyle) ?? .pixel }
        set {
            objectWillChange.send()
            storedFontStyle = newValue.rawValue
        }
    }

    var voiceOverOn: Bool {
        get { storedVoiceOver }
        set {
            objectWillChange.send()
            storedVoiceOver = newValue
        }
    }

    let dyslexicScale: CGFloat = 0.92
}
