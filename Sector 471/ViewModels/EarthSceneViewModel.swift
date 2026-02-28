//
//  EarthSceneViewModel.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 02/09/1447 AH.
//
//  DESCRIPTION (for the team):
//  EarthSceneViewModel drives the Earth scene text timeline.
//  It reads the Earth text from ScriptStore (Scripts.json) and plays it as a sequence of
//  typewriter animations + fade in/out transitions:
//
//  Timeline (high level):
//  1) Show the bottom dialogue text (typed) + fade in → hold → fade out
//  2) Switch to the top-left text (typed) → hold
//  3) Switch to the third/bottom text (typed) + fade in → hold → fade out
//  4) Fade to black at the end (EarthScene → next scene)
//
//  It uses a single sequence Task so it can be started once and cancelled safely.
//  It also uses a "typingToken" to cancel/ignore old typing tasks when the sequence changes
//  or when stop() is called (prevents text continuing to type after cancellation).
//
import SwiftUI
import Combine

@MainActor
final class EarthSceneViewModel: ObservableObject {

    @Published var typedBottomText: String = ""
    @Published var typedTopLeftText: String = ""
    @Published var typedThirdText: String = ""

    @Published var bottomOpacity: Double = 0.0

    @Published var showBottomText: Bool = true
    @Published var showTopLeftText: Bool = false
    @Published var showThirdText: Bool = false

    @Published var fadeToBlackOpacity: Double = 0.0

    let typeCharDelaySeconds: Double = 0.09
    let fadeInOutDuration: Double = 1.2

    private let scriptStore: ScriptStore

    private var sequenceTask: Task<Void, Never>?
    private var typingToken: Int = 0

    
    private var pause: PauseController?

    init(scriptStore: ScriptStore = .shared) {
        self.scriptStore = scriptStore
    }

    func configure(pause: PauseController) {
        self.pause = pause
    }

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

    private func runSequence() async {
        reset()
        guard let pause else { return }

        // 1) Bottom dialogue
        typingToken &+= 1
        let token1 = typingToken

        typedBottomText = ""
        showBottomText = true
        showTopLeftText = false
        showThirdText = false

        Task { [weak self] in
            guard let self else { return }
            await self.typeText(
                self.scriptStore.scripts.earth.dialogueText,
                into: { self.typedBottomText = $0 },
                token: token1
            )
        }

        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 1.0
        }

    
        await pause.sleep(seconds: 5.0)
        if Task.isCancelled { return }

        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 0.0
        }

        
        await pause.sleep(seconds: fadeInOutDuration)
        if Task.isCancelled { return }

        
        withAnimation(.easeInOut(duration: 0.5)) {
            showBottomText = false
            showTopLeftText = true
        }

        typingToken &+= 1
        let token2 = typingToken
        typedTopLeftText = ""

        await typeText(
            scriptStore.scripts.earth.topLeftText,
            into: { self.typedTopLeftText = $0 },
            token: token2
        )
        if Task.isCancelled { return }

       
        await pause.sleep(seconds: 4.0)
        if Task.isCancelled { return }

       
        withAnimation(.easeInOut(duration: 0.5)) {
            showTopLeftText = false
            showThirdText = true
        }

        typingToken &+= 1
        let token3 = typingToken
        typedThirdText = ""

        Task { [weak self] in
            guard let self else { return }
            await self.typeText(
                self.scriptStore.scripts.earth.thirdText,
                into: { self.typedThirdText = $0 },
                token: token3
            )
        }

        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 1.0
        }

     
        await pause.sleep(seconds: 5.0)
        if Task.isCancelled { return }

        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 0.0
        }

      
        await pause.sleep(seconds: fadeInOutDuration)
        if Task.isCancelled { return }

        // 4) Fade to black
        withAnimation(.easeInOut(duration: 1.0)) {
            fadeToBlackOpacity = 1.0
        }

      
        await pause.sleep(seconds: 1.0)
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

    private func typeText(
        _ full: String,
        into set: @escaping (String) -> Void,
        token: Int
    ) async {
        guard let pause else { return }

        var current = ""
        for ch in full {
            if Task.isCancelled { return }
            if token != typingToken { return }

            current.append(ch)
            set(current)

           
            await pause.sleep(seconds: typeCharDelaySeconds)
        }
    }
}
