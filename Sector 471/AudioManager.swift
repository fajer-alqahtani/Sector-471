//
//  AudioManager.swift
//  Sector 471
//
//  Created by Fajer alQahtani on 27/08/1447 AH.
//

import Foundation
import AVFoundation
import Combine

final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private init() { }
    private var controlledPlayers: [String: AVAudioPlayer] = [:]
    // MARK: - SFX
    func preloadSFX(_ files: [String]) {
        files.forEach { _ = makeSFXPlayerIfNeeded(for: $0) }
    }

    func playSFX(_ fileName: String, ext: String = "wav", volume: Float = 1.0) {
        guard let player = makeSFXPlayerIfNeeded(for: fileName, ext: ext) else { return }
        player.currentTime = 0
        player.volume = volume
        player.play()
    }

    private func makeSFXPlayerIfNeeded(for fileName: String, ext: String = "wav") -> AVAudioPlayer? {
        let key = "\(fileName).\(ext)"
        if let existing = sfxPlayers[key] { return existing }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("❌ Missing SFX file: \(key)")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            sfxPlayers[key] = player
            return player
        } catch {
            print("❌ Failed to load SFX \(key): \(error)")
            return nil
        }
    }
    
    func playLoopingSFX(_ fileName: String, ext: String = "m4a", volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Missing file")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // infinite loop
            player.volume = volume
            player.prepareToPlay()
            player.play()
            sfxPlayers["looping"] = player
        } catch {
            print(error)
        }
    }

    func stopLoopingSFX() {
        sfxPlayers["looping"]?.stop()
    }
    
    func startSound(name: String, ext: String = "m4a") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound not found: \(name).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()

            controlledPlayers[name] = player
        } catch {
            print("Error playing \(name):", error)
        }
    }
    
    func stopSound(name: String) {
        controlledPlayers[name]?.stop()
        controlledPlayers[name] = nil
    }

    // MARK: - Music
    func playMusic(_ fileName: String, ext: String = "mp3", volume: Float = 0.6, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("❌ Missing music file: \(fileName).\(ext)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loop ? -1 : 0
            player.volume = volume
            player.prepareToPlay()
            player.play()
            musicPlayer = player
        } catch {
            print("❌ Failed to play music: \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func setMusicVolume(_ v: Float) {
        musicPlayer?.volume = v
    }
}
