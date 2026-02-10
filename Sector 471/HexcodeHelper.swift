//
//  HexcodeHelper.swift
//  Sector 471
//
//  Created by Oroub Alelewi on 09/02/2026.
//
import SwiftUI

public extension Color {
    /// Initialize a SwiftUI Color from a hex string.
    /// Supports:
    /// - RGB (3 or 6 hex digits)
    /// - RGBA (4 or 8 hex digits)
    /// - With or without a leading "#"
    /// Examples: "#FA0", "FA0", "#FFA500", "FFA500FF"
    init?(hex: String) {
        let cleaned = Color.normalize(hexString: hex)
        guard let rgba = Color.parse(hex: cleaned) else {
            return nil
        }
        self = Color(.sRGB,
                     red: rgba.r,
                     green: rgba.g,
                     blue: rgba.b,
                     opacity: rgba.a)
    }

    /// Initialize a SwiftUI Color from a 24-bit or 32-bit integer.
    /// - Parameters:
    ///   - hex: When hasAlpha is false, format is 0xRRGGBB. When true, format is 0xRRGGBBAA.
    ///   - hasAlpha: Whether the provided integer includes an alpha component.
    init(hex: UInt32, hasAlpha: Bool = false) {
        let r, g, b, a: Double
        if hasAlpha {
            r = Double((hex & 0xFF000000) >> 24) / 255.0
            g = Double((hex & 0x00FF0000) >> 16) / 255.0
            b = Double((hex & 0x0000FF00) >> 8) / 255.0
            a = Double(hex & 0x000000FF) / 255.0
        } else {
            r = Double((hex & 0x00FF0000) >> 16) / 255.0
            g = Double((hex & 0x0000FF00) >> 8) / 255.0
            b = Double(hex & 0x000000FF) / 255.0
            a = 1.0
        }
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Returns a normalized hex string representation of this color, if it can be represented in sRGB.
    /// - Parameter includeAlpha: Include the alpha channel (RRGGBBAA) if true, otherwise (RRGGBB).
    func hexString(includeAlpha: Bool = false) -> String? {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        #elseif canImport(AppKit)
        let ns = NSColor(self)
        guard let rgb = ns.usingColorSpace(.sRGB) else { return nil }
        let r = rgb.redComponent
        let g = rgb.greenComponent
        let b = rgb.blueComponent
        let a = rgb.alphaComponent
        #endif

        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        if includeAlpha {
            let ai = Int(round(a * 255))
            return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        } else {
            return String(format: "#%02X%02X%02X", ri, gi, bi)
        }
    }
}

//Internal parsing helpers
private extension Color {
    struct RGBA {
        let r: Double
        let g: Double
        let b: Double
        let a: Double
    }

    static func normalize(hexString: String) -> String {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") {
            s.removeFirst()
        }
        return s
    }

    static func parse(hex s: String) -> RGBA? {
        switch s.count {
        case 3:
            // RGB (12-bit) -> expand to 24-bit
            let r = String(repeating: s[s.index(s.startIndex, offsetBy: 0)], count: 2)
            let g = String(repeating: s[s.index(s.startIndex, offsetBy: 1)], count: 2)
            let b = String(repeating: s[s.index(s.startIndex, offsetBy: 2)], count: 2)
            return componentsFrom(hexPairs: [r, g, b], alpha: "FF")
        case 4:
            // RGBA (16-bit) -> expand to 32-bit
            let r = String(repeating: s[s.index(s.startIndex, offsetBy: 0)], count: 2)
            let g = String(repeating: s[s.index(s.startIndex, offsetBy: 1)], count: 2)
            let b = String(repeating: s[s.index(s.startIndex, offsetBy: 2)], count: 2)
            let a = String(repeating: s[s.index(s.startIndex, offsetBy: 3)], count: 2)
            return componentsFrom(hexPairs: [r, g, b], alpha: a)
        case 6:
            // RRGGBB
            let r = String(s.prefix(2))
            let g = String(s.dropFirst(2).prefix(2))
            let b = String(s.dropFirst(4).prefix(2))
            return componentsFrom(hexPairs: [r, g, b], alpha: "FF")
        case 8:
            // RRGGBBAA
            let r = String(s.prefix(2))
            let g = String(s.dropFirst(2).prefix(2))
            let b = String(s.dropFirst(4).prefix(2))
            let a = String(s.dropFirst(6).prefix(2))
            return componentsFrom(hexPairs: [r, g, b], alpha: a)
        default:
            return nil
        }
    }

    static func componentsFrom(hexPairs: [String], alpha: String) -> RGBA? {
        guard hexPairs.count == 3 else { return nil }
        guard let r = UInt8(hexPairs[0], radix: 16),
              let g = UInt8(hexPairs[1], radix: 16),
              let b = UInt8(hexPairs[2], radix: 16),
              let a = UInt8(alpha, radix: 16) else {
            return nil
        }
        return RGBA(r: Double(r) / 255.0,
                    g: Double(g) / 255.0,
                    b: Double(b) / 255.0,
                    a: Double(a) / 255.0)
    }
}
