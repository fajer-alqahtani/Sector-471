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

    // MARK: - Published UI state
    /// Typewriter output for the first (bottom) dialogue block.
    @Published var typedBottomText: String = ""

    /// Typewriter output for the top-left text block.
    @Published var typedTopLeftText: String = ""

    /// Typewriter output for the third text block (shown later).
    @Published var typedThirdText: String = ""

    /// Opacity used for fading the bottom text blocks in/out.
    /// (Reused for both the first and third bottom text phases.)
    @Published var bottomOpacity: Double = 0.0

    /// Controls which text block is currently visible.
    @Published var showBottomText: Bool = true
    @Published var showTopLeftText: Bool = false
    @Published var showThirdText: Bool = false

    /// Final fade-to-black overlay opacity (0 → 1 at end of sequence).
    @Published var fadeToBlackOpacity: Double = 0.0

    // MARK: - Config
    /// Delay between characters in the typewriter effect.
    let typeCharDelaySeconds: Double = 0.09

    /// Duration for fade in/out animations.
    let fadeInOutDuration: Double = 1.2

    // MARK: - Dependencies
    /// Source of decoded scripts (Scripts.json).
    private let scriptStore: ScriptStore

    // MARK: - Task control
    /// Runs the full timeline so we can cancel safely when the view disappears.
    private var sequenceTask: Task<Void, Never>?

    /// Token used to invalidate/stop older typing tasks.
    /// Every time we start a new typing phase (or call stop), we increment the token.
    private var typingToken: Int = 0

    /// Default dependency is the shared ScriptStore.
    init(scriptStore: ScriptStore = .shared) {
        self.scriptStore = scriptStore
    }

    // MARK: - Public API
    /// Starts the Earth scene sequence.
    /// Guard prevents multiple overlapping sequences if start() is called again.
    func start() {
        if sequenceTask != nil { return }
        sequenceTask = Task { [weak self] in
            guard let self else { return }
            await self.runSequence()
        }
    }

    /// Stops the current sequence and invalidates any in-progress typing tasks.
    func stop() {
        sequenceTask?.cancel()
        sequenceTask = nil

        // Invalidate any ongoing typewriter loops immediately.
        typingToken &+= 1
    }

    // MARK: - Sequence
    /// Runs the full Earth scene timeline (see file header description).
    private func runSequence() async {
        reset()

        // =========================
        // 1) Bottom dialogue phase
        // =========================

        // New token for this typing phase.
        typingToken &+= 1
        let token1 = typingToken

        // Reset text + visibility flags.
        typedBottomText = ""
        showBottomText = true
        showTopLeftText = false
        showThirdText = false

        // Start typewriter in a child task so it can run while we also manage fades/timers.
        Task { [weak self] in
            guard let self else { return }
            await self.typeText(
                self.scriptStore.scripts.earth.dialogueText,
                into: { self.typedBottomText = $0 },
                token: token1
            )
        }

        // Fade in the bottom text.
        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 1.0
        }

        // Hold (and allow typing to continue).
        try? await Task.sleep(nanoseconds: 5_000_000_000)

        // Fade out the bottom text.
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 0.0
        }
        try? await Task.sleep(nanoseconds: UInt64(fadeInOutDuration * 1_000_000_000))

        // =========================
        // 2) Top-left text phase
        // =========================

        // Switch visibility from bottom → top-left.
        withAnimation(.easeInOut(duration: 0.5)) {
            showBottomText = false
            showTopLeftText = true
        }

        // New token for this typing phase.
        typingToken &+= 1
        let token2 = typingToken
        typedTopLeftText = ""

        // Type top-left text (awaited here because we don’t need concurrent fade timing).
        await typeText(
            scriptStore.scripts.earth.topLeftText,
            into: { self.typedTopLeftText = $0 },
            token: token2
        )

        // Hold the top-left text on screen.
        try? await Task.sleep(nanoseconds: 4_000_000_000)

        // =========================
        // 3) Third/bottom text phase
        // =========================

        // Switch visibility from top-left → third text.
        withAnimation(.easeInOut(duration: 0.5)) {
            showTopLeftText = false
            showThirdText = true
        }

        // New token for this typing phase.
        typingToken &+= 1
        let token3 = typingToken
        typedThirdText = ""

        // Start typewriter in a child task so it can run during fade timing.
        Task { [weak self] in
            guard let self else { return }
            await self.typeText(
                self.scriptStore.scripts.earth.thirdText,
                into: { self.typedThirdText = $0 },
                token: token3
            )
        }

        // Fade in the third text (reusing bottomOpacity as the fade driver).
        bottomOpacity = 0.0
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 1.0
        }

        // Hold.
        try? await Task.sleep(nanoseconds: 5_000_000_000)

        // Fade out.
        withAnimation(.easeInOut(duration: fadeInOutDuration)) {
            bottomOpacity = 0.0
        }
        try? await Task.sleep(nanoseconds: UInt64(fadeInOutDuration * 1_000_000_000))

        // =========================
        // 4) Fade to black (end)
        // =========================

        // Fade to black to transition out of the Earth scene.
        withAnimation(.easeInOut(duration: 1.0)) {
            fadeToBlackOpacity = 1.0
        }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    /// Resets UI state to the initial values (ready to run again).
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

    /// Typewriter effect:
    /// Writes `full` into the provided setter one character at a time.
    /// Stops if:
    /// - the parent Task is cancelled, or
    /// - the token no longer matches (meaning a newer typing phase started).
    private func typeText(
        _ full: String,
        into set: @escaping (String) -> Void,
        token: Int
    ) async {
        var current = ""
        for ch in full {

            // Stop typing if the whole sequence was cancelled.
            if Task.isCancelled { return }

            // Stop typing if a newer typing phase started (token changed).
            if token != typingToken { return }

            current.append(ch)
            set(current)

            // Delay per character.
            try? await Task.sleep(nanoseconds: UInt64(typeCharDelaySeconds * 1_000_000_000))
        }
    }
}
