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

    // Cache to avoid recalculating a lot
    private static var scaleCache: [String: CGFloat] = [:]

    static func fontName(for style: AppFontStyle) -> String {
        switch style {
        case .pixel: return AppFonts.pixel
        case .dyslexic: return AppFonts.dyslexic
        }
    }

    /// Computes a "visual" scale so the target font looks the same size as the reference font.
    /// We use capHeight (or xHeight) which tends to match perceived size better than pointSize.
    private static func calibratedScale(
        referenceFontName: String,
        targetFontName: String,
        basePointSize: CGFloat
    ) -> CGFloat {
        let key = "\(referenceFontName)|\(targetFontName)|\(basePointSize)"
        if let cached = scaleCache[key] { return cached }

        guard
            let ref = UIFont(name: referenceFontName, size: basePointSize),
            let target = UIFont(name: targetFontName, size: basePointSize)
        else {
            return 1.0
        }

        // Use capHeight as the main signal (you can switch to xHeight if it feels better)
        let refMetric = ref.capHeight
        let targetMetric = target.capHeight

        guard targetMetric > 0 else { return 1.0 }

        var scale = refMetric / targetMetric

        // Clamp to avoid weird extremes if fonts are missing/mis-registered
        scale = min(max(scale, 0.80), 1.05)

        scaleCache[key] = scale
        return scale
    }

    /// Returns a fixed-size custom font (manual sizing for game UI).
    static func fixed(_ size: CGFloat, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)

        if settings.fontStyle == .dyslexic {
            let s = calibratedScale(
                referenceFontName: AppFonts.pixel,
                targetFontName: AppFonts.dyslexic,
                basePointSize: size
            )
            return .custom(name, size: size * s)
        } else {
            return .custom(name, size: size)
        }
    }

    /// Returns a Dynamic Type-aware font (still uses calibration to keep layouts stable).
    static func dynamic(_ textStyle: Font.TextStyle, settings: AppAccessibilitySettings) -> Font {
        let name = fontName(for: settings.fontStyle)
        let base = UIFont.preferredFont(forTextStyle: uiTextStyle(from: textStyle)).pointSize

        if settings.fontStyle == .dyslexic {
            let s = calibratedScale(
                referenceFontName: AppFonts.pixel,
                targetFontName: AppFonts.dyslexic,
                basePointSize: base
            )
            return .custom(name, size: base * s, relativeTo: textStyle)
        } else {
            return .custom(name, size: base, relativeTo: textStyle)
        }
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

    /// Convenience modifier used throughout the app:
    /// `Text("Hello").appFixedFont(40, settings: accessibility)`
    ///
    /// This keeps font usage consistent and ensures the selected accessibility style is applied.
    func appFixedFont(_ size: CGFloat, settings: AppAccessibilitySettings) -> some View {
        font(AppTypography.fixed(size, settings: settings))
    }
}
