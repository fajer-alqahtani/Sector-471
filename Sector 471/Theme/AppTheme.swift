//
//  AppTheme.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import UIKit

// MARK: - Settings Keys
enum SettingsKeys {
    static let fontStyle = "game_font_style"
    static let voiceOver = "voice_over_on"
}

// MARK: - Fonts
enum AppFontStyle: String {
    case pixel
    case dyslexic
}

enum AppFonts {
    static let pixel = "PixelifySans-Medium"
    static let dyslexic = "OpenDyslexic-Bold"
}

// MARK: - Typography
struct AppTypography {

    static func fontName(for style: AppFontStyle) -> String {
        switch style {
        case .pixel: return AppFonts.pixel
        case .dyslexic: return AppFonts.dyslexic
        }
    }

    static func fixed(_ size: CGFloat, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)
        let scale: CGFloat = (settings.fontStyle == .dyslexic) ? settings.dyslexicScale : 1.0
        return .custom(name, size: size * scale)
    }

    static func dynamic(_ textStyle: Font.TextStyle, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)
        let base = UIFont.preferredFont(forTextStyle: uiTextStyle(from: textStyle)).pointSize
        let scale: CGFloat = (settings.fontStyle == .dyslexic) ? settings.dyslexicScale : 1.0
        return .custom(name, size: base * scale, relativeTo: textStyle)
    }

    private static func uiTextStyle(from style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}

// MARK: - View helper
extension View {
    func appFixedFont(_ size: CGFloat, settings: AppAccessibilitySettings) -> some View {
        font(AppTypography.fixed(size, settings: settings))
    }
}
