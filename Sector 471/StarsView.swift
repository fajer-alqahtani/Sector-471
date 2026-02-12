//
//  StarsView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
import SwiftUI

struct StarsView: View {
    @State private var currentLinesName: String? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("Stars")
                .resizable()
                .scaledToFill()

            if let name = currentLinesName {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
        }
        .task { await runLinesSequence() }
    }

    private func runLinesSequence() async {
        let shortTime: Double = 2.5
        let longTime: Double  = 3.5
        let extraTime: Double = 4.5
        let stay: Double      = 10.5

        let steps: [(String, Double)] = [
            ("Lines1", shortTime),
            ("Lines2", shortTime),
            ("Lines3", shortTime),
            ("Lines4", shortTime),
            ("Lines5", shortTime),
            ("Lines6", longTime),
            ("Lines7", longTime),
            ("Lines8", extraTime),
            ("Lines9", stay)
        ]

        for step in steps {
            let (name, duration) = step

            await MainActor.run { currentLinesName = name }
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            await MainActor.run { currentLinesName = nil }
        }
    }
}

#Preview ("Landscape Preview", traits: .landscapeLeft){
    StarsView()
}

