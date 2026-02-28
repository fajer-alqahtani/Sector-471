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

    // For long / main audio (your scene audio)
    private var player: AVAudioPlayer?

    // For short rapid SFX (typing)
    private var typingPlayer: AVAudioPlayer?

    func playAudio(named name: String, ext: String = "m4a", volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Audio file not found:", "\(name).\(ext)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = volume
            player?.prepareToPlay()
            player?.play()
            print("✅ Playing:", "\(name).\(ext)")
        } catch {
            print("❌ Audio error:", error)
        }
    }

    func stopAudio() {
        player?.stop()
        player = nil
    }

    // MARK: - Typing SFX

    /// Call ONCE (ex: onAppear) to preload the typing sound
    func prepareTypingSFX(named name: String, ext: String = "mp3", volume: Float = 0.5) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Typing SFX not found:", "\(name).\(ext)")
            return
        }

        do {
            typingPlayer = try AVAudioPlayer(contentsOf: url)
            typingPlayer?.volume = volume
            typingPlayer?.prepareToPlay()
            print("✅ Typing SFX prepared:", "\(name).\(ext)")
        } catch {
            print("❌ Typing SFX error:", error)
        }
    }

    /// Call during typing (fast replay)
    func playTypingTick() {
        guard let typingPlayer else { return }
        typingPlayer.currentTime = 0
        typingPlayer.play()
    }

    func stopTypingSFX() {
        typingPlayer?.stop()
        typingPlayer = nil
    }
}
