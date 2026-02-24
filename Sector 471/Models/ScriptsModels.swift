//
//  ScriptsModels.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  This file contains the Codable data models that match the structure of Scripts.json.
//  We decode Scripts.json into these structs so each scene can read its own text safely.
//  It also includes a `fallback` value used when the JSON fails to load, so the app
//  won’t crash and we can clearly see that the scripts are missing.
//

import Foundation

/// Root model that represents the entire Scripts.json file.
/// Each property maps to a scene section in the JSON.
struct Scripts: Codable {

    // Text content used by UniversalScene
    let universal: UniversalScript

    // Text content used by EarthScene
    let earth: EarthScript

    /// Safe default used when Scripts.json is missing or decoding fails.
    /// This prevents crashes and makes the failure obvious in the UI.
    static let fallback = Scripts(
        universal: UniversalScript(quoteText: "[FALLBACK] Scripts.json not loaded"),
        earth: EarthScript(
            dialogueText: "[FALLBACK] Scripts.json not loaded",
            topLeftText: "",
            thirdText: ""
        )
    )
}

/// Universal scene script section.
/// Matches: { "universal": { "quoteText": "..." } }
struct UniversalScript: Codable {

    // Main quote text shown in the UniversalScene
    let quoteText: String
}

/// Earth scene script section.
/// Matches: { "earth": { "dialogueText": "...", "topLeftText": "...", "thirdText": "..." } }
struct EarthScript: Codable {

    // Main dialogue/paragraph text shown in the Earth scene
    let dialogueText: String

    // Short text displayed at the top-left (UI overlay label)
    let topLeftText: String

    // Additional text block used later in the Earth scene flow
    let thirdText: String
}
