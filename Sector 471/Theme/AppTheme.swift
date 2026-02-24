//
//  AppTheme.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  This file centralizes the app’s theme typography + accessibility font switching.
//  It defines:
//  1) Keys used for saving settings in UserDefaults (via @AppStorage).
//  2) The available font styles (Pixel vs Dyslexic-friendly).
//  3) The actual font file names used in the project.
//  4) Helper functions to return a SwiftUI Font that respects the selected style,
//     including a small scale tweak for dyslexic font to keep layouts consistent.
//  5) A View extension (appFixedFont) so views can apply the correct font in one line.
//

import SwiftUI
import UIKit

// MARK: - Settings Keys
/// UserDefaults keys used by @AppStorage (see AppAccessibilitySettings).
enum SettingsKeys {
    static let fontStyle = "game_font_style"  // saved font style selection
    static let voiceOver = "voice_over_on"    // saved voiceOver toggle
}

// MARK: - Fonts
/// The supported font styles in the app.
/// Raw values are stored in UserDefaults via @AppStorage.
enum AppFontStyle: String {
    case pixel
    case dyslexic
}

/// The actual font file/postscript names registered in the project.
/// (These must match the names in your font files / Info.plist registration.)
enum AppFonts {
    static let pixel = "PixelifySans-Medium"
    static let dyslexic = "OpenDyslexic-Bold"
}

// MARK: - Typography
/// Typography helper that builds SwiftUI Fonts based on the selected accessibility settings.
struct AppTypography {

    /// Returns the correct font name for the currently selected style.
    static func fontName(for style: AppFontStyle) -> String {
        switch style {
        case .pixel: return AppFonts.pixel
        case .dyslexic: return AppFonts.dyslexic
        }
    }

    /// Returns a fixed-size custom font (good for game UI where sizes are controlled manually).
    /// Applies a small scale adjustment when dyslexic font is active to avoid oversized layouts.
    static func fixed(_ size: CGFloat, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)
        let scale: CGFloat = (settings.fontStyle == .dyslexic) ? settings.dyslexicScale : 1.0
        return .custom(name, size: size * scale)
    }

    /// Returns a Dynamic Type-aware font.
    /// - Uses the system preferred point size for the given text style
    /// - Then applies the selected custom font
    /// - Still respects Dynamic Type scaling via `relativeTo:`
    /// - Applies dyslexic scale tweak to keep the UI from growing too much
    static func dynamic(_ textStyle: Font.TextStyle, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)

        // Convert SwiftUI text style -> UIKit text style so we can read the user's preferred size.
        let base = UIFont.preferredFont(forTextStyle: uiTextStyle(from: textStyle)).pointSize

        // Slight downscale for dyslexic font to maintain visual balance.
        let scale: CGFloat = (settings.fontStyle == .dyslexic) ? settings.dyslexicScale : 1.0

        // `relativeTo` keeps Dynamic Type scaling behavior while still using our custom font.
        return .custom(name, size: base * scale, relativeTo: textStyle)
    }

    /// Helper that maps SwiftUI Font.TextStyle values to their UIKit equivalents.
    /// This is needed because preferredFont(forTextStyle:) is a UIKit API.
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
        @unknown default: return .body // fallback if Apple adds new cases in the future
        }
    }
}

// MARK: - View helper
extension View {

    /// Convenience modifier used throughout the app:
    /// `Text("Hello").appFixedFont(40, settings: accessibility)`
    ///
    /// This keeps font usage consistent and ensures the selected accessibility style is applied.
    func appFixedFont(_ size: CGFloat, settings: AppAccessibilitySettings) -> some View {
        font(AppTypography.fixed(size, settings: settings))
    }
}
