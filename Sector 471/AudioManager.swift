//
//  AudioManager.swift
//  Sector 471
//
//  Created by Fajer alQahtani on 27/08/1447 AH.
//


import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private init() {}

    private var player: AVAudioPlayer?

    func playAudio(named name: String, ext: String = "m4a") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Audio file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ Audio error:", error)
        }
    }

    func stopAudio() {
        player?.stop()
        player = nil
    }
}
