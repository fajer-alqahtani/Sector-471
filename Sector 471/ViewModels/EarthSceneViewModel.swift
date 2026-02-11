//
//  EarthSceneViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class EarthSceneViewModel: ObservableObject {

    // MARK: - Published UI state
    @Published var typedBottomText: String = ""
    @Published var typedTopLeftText: String = ""
    @Published var typedThirdText: String = ""

    @Published var bottomOpacity: Double = 0.0

    @Published var showBottomText: Bool = true
    @Published var showTopLeftText: Bool = false
    @Published var showThirdText: Bool = false

    @Published var fadeToBlackOpacity: Double = 0.0

    // MARK: - Config
    let typeCharDelaySeconds: Double = 0.09
    let fadeInOutDuration: Double = 1.2

    // MARK: - Dependencies
    private let scriptStore: ScriptStore

    // MARK: - Task control
    private var sequenceTask: Task<Void, Never>?
    private var typingToken: Int = 0

    init(scriptStore: ScriptStore = .shared) {
        self.scriptStore = scriptStore
    }

    // MARK: - Public API
    func start() {
        if sequenceTask != nil { return }
        sequenceTask = Task { [weak self] in
            guard let self else { return }
            await self.runSequence()
        }
    }

    func stop() {
        sequenceTask?.cancel()
        sequenceTask = nil

        
        typingToken &+= 1
    }

    // MARK: - Sequence
    private func runSequence() async {
        reset()

 
        typingToken &+= 1
        let token1 = typingToken

        typedBottomText = ""
        showBottomText = true
        showTopLeftText = false
        showThirdText = false

        Task { [weak self] in
            guard let self else { return }
            await self.typeText(self.scriptStore.scripts.earth.dialogueText,
                                into: { self.typedBottomText = $0 },
                                token: token1)
        }

        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) { bottomOpacity = 1.0 }

        try? await Task.sleep(nanoseconds: 5_000_000_000)

        withAnimation(.easeInOut(duration: fadeInOutDuration)) { bottomOpacity = 0.0 }
        try? await Task.sleep(nanoseconds: UInt64(fadeInOutDuration * 1_000_000_000))

       
        withAnimation(.easeInOut(duration: 0.5)) {
            showBottomText = false
            showTopLeftText = true
        }

        typingToken &+= 1
        let token2 = typingToken
        typedTopLeftText = ""

        await typeText(scriptStore.scripts.earth.topLeftText,
                       into: { self.typedTopLeftText = $0 },
                       token: token2)

        try? await Task.sleep(nanoseconds: 4_000_000_000)

      
        withAnimation(.easeInOut(duration: 0.5)) {
            showTopLeftText = false
            showThirdText = true
        }

        typingToken &+= 1
        let token3 = typingToken
        typedThirdText = ""

        Task { [weak self] in
            guard let self else { return }
            await self.typeText(self.scriptStore.scripts.earth.thirdText,
                                into: { self.typedThirdText = $0 },
                                token: token3)
        }

        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) { bottomOpacity = 1.0 }

        try? await Task.sleep(nanoseconds: 5_000_000_000)

        withAnimation(.easeInOut(duration: fadeInOutDuration)) { bottomOpacity = 0.0 }
        try? await Task.sleep(nanoseconds: UInt64(fadeInOutDuration * 1_000_000_000))

       
        withAnimation(.easeInOut(duration: 1.0)) { fadeToBlackOpacity = 1.0 }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    private func reset() {
        typedBottomText = ""
        typedTopLeftText = ""
        typedThirdText = ""

        bottomOpacity = 0.0
        showBottomText = true
        showTopLeftText = false
        showThirdText = false

        fadeToBlackOpacity = 0.0
    }

    private func typeText(_ full: String,
                          into set: @escaping (String) -> Void,
                          token: Int) async {
        var current = ""
        for ch in full {
            if Task.isCancelled { return }
            if token != typingToken { return }

            current.append(ch)
            set(current)

            try? await Task.sleep(nanoseconds: UInt64(typeCharDelaySeconds * 1_000_000_000))
        }
    }
}
