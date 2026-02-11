//
//  ScriptStore.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//

import Foundation
import Combine

@MainActor
final class ScriptStore: ObservableObject {
    static let shared = ScriptStore()

    @Published private(set) var scripts: Scripts = .fallback
    @Published private(set) var errorMessage: String? = nil

    private init() { load() }

    func reload() { load() }

    private func load() {
        print("🚀 ScriptStore.load() called")

        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        print("📦 JSON in Bundle.main:", urls.map { $0.lastPathComponent })

        guard let url = Bundle.main.url(forResource: "Scripts", withExtension: "json") else {
            let msg = "❌ Scripts.json NOT FOUND in Bundle. Check Target Membership + Copy Bundle Resources."
            print(msg)
            errorMessage = msg
            scripts = .fallback
            return
        }

        print("✅ Found Scripts.json at:", url.path)

        do {
            let data = try Data(contentsOf: url)
            print("✅ Read Scripts.json bytes:", data.count)

            let preview = String(data: data.prefix(120), encoding: .utf8) ?? "nil"
            print("🔎 Scripts.json preview:", preview)

            let cleanedData: Data
            if data.starts(with: [0xEF, 0xBB, 0xBF]) {
                cleanedData = data.dropFirst(3)
                print("🧹 Stripped UTF-8 BOM")
            } else {
                cleanedData = data
            }

            let decoded = try JSONDecoder().decode(Scripts.self, from: cleanedData)

            scripts = decoded
            errorMessage = nil
            print("✅ Decoded universal quote:", decoded.universal.quoteText)

        } catch {
            let msg = "❌ Failed to load/decode Scripts.json: \(error)"
            print(msg)
            errorMessage = msg
            scripts = .fallback
        }
    }
}
