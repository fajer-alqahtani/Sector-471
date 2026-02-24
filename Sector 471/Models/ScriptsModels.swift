
//  ScriptsModels.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 27/08/1447 AH.
//

import Foundation


struct Scripts: Codable {
    let universal: UniversalScript
    let earth: EarthScript

    static let fallback = Scripts(
        universal: UniversalScript(quoteText: "[FALLBACK] Scripts.json not loaded"),
        earth: EarthScript(
            dialogueText: "[FALLBACK] Scripts.json not loaded",
            topLeftText: "",
            thirdText: ""
        )
    )
}

struct UniversalScript: Codable {
    let quoteText: String
}

struct EarthScript: Codable {
    let dialogueText: String
    let topLeftText: String
    let thirdText: String
}
