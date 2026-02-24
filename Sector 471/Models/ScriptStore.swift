//
//  ScriptStore.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  ScriptStore is the central manager responsible for loading Scripts.json from the app bundle,
//  decoding it into our Codable models (Scripts / UniversalScript / EarthScript), and exposing
//  the result to SwiftUI views.
//  - It is a singleton (shared) so every scene reads the same script data.
//  - It runs on the MainActor because it updates @Published properties that drive the UI.
//  - It always provides a safe fallback (Scripts.fallback) if the file is missing or decoding fails.
//  - It also stores an errorMessage for debugging or showing an in-app error state.
//  The debug prints help verify bundle inclusion, path, byte size, preview, BOM stripping, and decoding.
//

import Foundation
import Combine

@MainActor
final class ScriptStore: ObservableObject {

    /// Shared singleton instance so the whole app reads the same decoded scripts.
    static let shared = ScriptStore()

    /// The decoded scripts from Scripts.json.
    /// `private(set)` prevents external code from overwriting scripts directly.
    @Published private(set) var scripts: Scripts = .fallback

    /// Optional error message when loading/decoding fails (useful for debugging UI).
    @Published private(set) var errorMessage: String? = nil

    /// Private init ensures singleton usage.
    /// Loads scripts immediately on first access.
    private init() { load() }

    /// Public API to reload scripts (useful during development/testing).
    func reload() { load() }

    /// Loads Scripts.json from the app bundle and decodes it into `Scripts`.
    /// If anything fails, sets `scripts` back to `.fallback` and records `errorMessage`.
    private func load() {
        print("🚀 ScriptStore.load() called")

        // Debug: list all JSON files in the main bundle to confirm Scripts.json is included.
        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("📦 JSON in Bundle.main:", urls.map { $0.lastPathComponent })

        // Locate Scripts.json in the app bundle.
        guard let url = Bundle.main.url(forResource: "Scripts", withExtension: "json") else {
            let msg = "❌ Scripts.json NOT FOUND in Bundle. Check Target Membership + Copy Bundle Resources."
            print(msg)

            // Record the error and provide fallback content so the app continues safely.
            errorMessage = msg
            scripts = .fallback
            return
        }

        print("✅ Found Scripts.json at:", url.path)

        do {
            // Read the raw JSON file data.
            let data = try Data(contentsOf: url)
            print("✅ Read Scripts.json bytes:", data.count)

            // Debug: print a small preview of the JSON to quickly spot formatting issues.
            let preview = String(data: data.prefix(120), encoding: .utf8) ?? "nil"
            print("🔎 Scripts.json preview:", preview)

            // Some files can contain a UTF-8 BOM (Byte Order Mark) which breaks decoding.
            // This strips BOM bytes if they exist.
            let cleanedData: Data
            if data.starts(with: [0xEF, 0xBB, 0xBF]) {
                cleanedData = data.dropFirst(3)
                print("🧹 Stripped UTF-8 BOM")
            } else {
                cleanedData = data
            }

            // Decode JSON into our Scripts model.
            let decoded = try JSONDecoder().decode(Scripts.self, from: cleanedData)

            // Publish decoded scripts to update any SwiftUI views using them.
            scripts = decoded
            errorMessage = nil

            // Debug: confirm we decoded a real value.
            print("✅ Decoded universal quote:", decoded.universal.quoteText)

        } catch {
            // If reading or decoding fails, log the error and fall back safely.
            let msg = "❌ Failed to load/decode Scripts.json: \(error)"
            print(msg)

            errorMessage = msg
            scripts = .fallback
        }
    }
}
