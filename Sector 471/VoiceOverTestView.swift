//
//  VoiceOverTestView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//

import SwiftUI
import AVFoundation

struct VoiceOverTestView: View {
    @State private var voiceOverMode: Bool = false
    @State private var index: Int = 0

    private let synth = AVSpeechSynthesizer()

    private let lines: [String] = [
        "Mission log, entry 41.",
        "I am entering orbit around a planet designated Earth.",
        "Unexpected instability detected."
    ]

    var body: some View {
        ZStack {
            // ✅ Forest background
            Image("Forest")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // ✅ Dark overlay for readability
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("VoiceOver Mode Test")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                Toggle(isOn: $voiceOverMode) {
                    Text("VoiceOver Mode")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                .padding()
                .background(Color.black.opacity(0.55))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .onChange(of: voiceOverMode) { _, newValue in
                    if newValue { speak(lines[index]) }
                }

                // Dialogue card
                VStack(alignment: .leading, spacing: 12) {
                    Text(lines[index])
                        .foregroundStyle(.white)
                        .font(voiceOverMode ? .title3.weight(.semibold) : .body)
                        // ✅ Real VoiceOver will read this if VoiceOver is ON in system settings
                        .accessibilityLabel(lines[index])

                    HStack {
                        Button("Back") {
                            if index > 0 {
                                index -= 1
                                if voiceOverMode { speak(lines[index]) }
                            }
                        }
                        .disabled(index == 0)
                        .opacity(index == 0 ? 0.4 : 1)

                        Spacer()

                        Button(index == lines.count - 1 ? "Done" : "Next") {
                            if index < lines.count - 1 {
                                index += 1
                                if voiceOverMode { speak(lines[index]) }
                            } else {
                                if voiceOverMode { speak("Done.") }
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.plain)
                }
                .padding(18)
                .background(Color.black.opacity(0.75))
                .cornerRadius(18)
                .padding(.horizontal, 18)

                Text(voiceOverMode
                     ? "Auto-speak is ON (using AVSpeechSynthesizer)."
                     : "Auto-speak is OFF.")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.footnote)

                Spacer()
            }
        }
    }

    private func speak(_ text: String) {
        // Stop previous speech so it feels instant
        synth.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synth.speak(utterance)
    }
}

#Preview {
    VoiceOverTestView()
}
