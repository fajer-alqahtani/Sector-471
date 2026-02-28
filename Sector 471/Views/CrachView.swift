//
//  CrachView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  CrashView is the final cinematic scene.
//  It renders a layered background (Forest + Shuttle + Fireflies + Alert overlay) and then plays
//  a timed fade-to-black image sequence driven by CrashViewModel.
//  The view also begins with a full-screen white overlay that fades out (whiteStartOpacity),
//  revealing the scene underneath.
//
//  Architecture:
//  - CrashViewModel owns the whole timeline and publishes UI state:
//      * sceneOpacity + whiteStartOpacity (initial reveal)
//      * fadeCurrent / fadeNext / nextOpacity (smooth crossfade between fade images)
//      * showFinalBackground (final state)
//  - CrashView renders pure visuals; the view model controls timing + animation triggers.
//  - FirefliesLayer + AlertLastBreathOverlay are private visual helpers local to this file.
//
//  Notes:
//  - The view starts the timeline onAppear and cancels it onDisappear to avoid duplicate tasks.
//  - scale(for:) normalizes effects for different device sizes using a base iPad layout.
//

import SwiftUI

struct CrashView: View {

    @EnvironmentObject private var pause: PauseController
    @StateObject private var vm = CrashViewModel()

    var body: some View {
        GeometryReader { geo in
            let s = scale(for: geo.size)

            ZStack {
                sceneLayer(scale: s, size: geo.size)
                    .opacity(vm.sceneOpacity)

                Color.white
                    .ignoresSafeArea()
                    .opacity(vm.whiteStartOpacity)
                    .allowsHitTesting(false)
                    .zIndex(50_000)
            }
            .onAppear {
                vm.configure(pause: pause)
                vm.start()
            }
            .onDisappear { vm.stop() }
        }
    }

    private func scale(for size: CGSize) -> CGFloat {
        let baseW: CGFloat = 1366
        let baseH: CGFloat = 1024
        return min(size.width / baseW, size.height / baseH)
    }

    @ViewBuilder
    private func sceneLayer(scale s: CGFloat, size: CGSize) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image("Forest")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            FirefliesLayer(count: vm.fireflyCount, size: size, scale: s)
                .allowsHitTesting(false)

            Image("Shuttle")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            AlertLastBreathOverlay(scale: s)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            if let current = vm.fadeCurrent {
                Image(current)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .zIndex(900)
            }

            if let next = vm.fadeNext {
                Image(next)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(vm.nextOpacity)
                    .zIndex(901)
            }

            if vm.showFinalBackground {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .zIndex(999)
            }
        }
    }
}

// MARK: - Alert overlay
/// Animated alert overlay used in CrashView.
/// Uses TimelineView to update every frame and compute a flicker pattern over time.
private struct AlertLastBreathOverlay: View {

    // Scale multiplier passed from CrashView to keep glow consistent across devices.
    var scale: CGFloat = 1.0

    // Start time used as the reference for the timeline animation.
    @State private var startTime: Date = Date()

    // Tunable glow settings.
    private var glowAmount: Double { 2.25 }
    private var glowDistance: CGFloat { 65 * scale }
    private var glowSoftness: CGFloat { 68 * scale }

    var body: some View {
        TimelineView(.animation) { timeline in
            // Elapsed time since the overlay started (seconds).
            let t = timeline.date.timeIntervalSince(startTime)

            // First phase: short "blip" flickers.
            let blipPhaseEnd: Double = 6.5

            // Second phase: stronger "last breath" surge then decay.
            let lastBreathStart: Double = blipPhaseEnd
            let lastBreathDuration: Double = 4.2
            let endTime = lastBreathStart + lastBreathDuration

            // Compute alert opacity based on elapsed time.
            let alertOpacity: Double = {

                // Phase 1: hard-coded blink pattern (blips).
                if t < blipPhaseEnd {
                    let phase = t.truncatingRemainder(dividingBy: 2.6)
                    switch phase {
                    case 0.00..<0.10: return 1.00
                    case 0.10..<0.18: return 0.00
                    case 0.18..<0.30: return 0.90
                    case 0.30..<0.50: return 0.00
                    case 0.50..<0.60: return 0.70
                    default: return 0.00
                    }
                }

                // Phase 2: “last breath” surge → hold → decay + noisy flicker.
                if t < endTime {
                    let u = (t - lastBreathStart) / lastBreathDuration // normalize 0→1
                    let surgeEnd = 0.18
                    let holdEnd  = 0.52

                    // Base envelope: ease up → hold → ease down.
                    let base: Double
                    if u < surgeEnd {
                        base = easeOut(u / surgeEnd)
                    } else if u < holdEnd {
                        base = 1.0
                    } else {
                        let v = (u - holdEnd) / (1.0 - holdEnd)
                        base = 1.0 - easeIn(v)
                    }

                    // Increase flicker intensity as it “dies out”.
                    let dyingBoost = (u < holdEnd) ? 0.25 : (0.25 + (u - holdEnd) * 0.9)

                    // Two sine waves create a layered flicker.
                    let flicker =
                        1.0
                        - dyingBoost * 0.35 * (0.5 + 0.5 * sin((t - lastBreathStart) * 18.0))
                        - dyingBoost * 0.18 * (0.5 + 0.5 * sin((t - lastBreathStart) * 41.0 + 1.4))

                    // Late stage “snap” instability near the end.
                    let snapZone = max(0.0, (u - 0.80) / 0.20)
                    let snaps = 1.0 - snapZone * 0.45 * (0.5 + 0.5 * sin((t - lastBreathStart) * 55.0))

                    // Clamp to [0,1] for safety.
                    return max(0.0, min(1.0, base * flicker * snaps))
                }

                // After the sequence finishes, alert is off.
                return 0.0
            }()

            // Glow opacity is a boosted version of the alert (clamped).
            let glowOpacity = min(1.0, alertOpacity * glowAmount)

            ZStack {
                // Glow layer: yellow screen blend + blur + shadow for bloom effect.
                Image("Alert only")
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(.yellow)
                    .blendMode(.screen)
                    .opacity(glowOpacity)
                    .blur(radius: glowSoftness)
                    .scaleEffect(1.0 + glowDistance / 300.0)
                    .shadow(
                        color: Color.yellow.opacity(glowOpacity),
                        radius: glowDistance,
                        x: 0, y: 0
                    )

                // Core alert layer: the main alert image with small brightness boost.
                Image("Alert only")
                    .resizable()
                    .scaledToFill()
                    .opacity(alertOpacity)
                    .brightness(alertOpacity > 0.01 ? 0.10 : 0.0)
            }
        }
        // Reset start time whenever this overlay appears.
        .onAppear { startTime = Date() }
    }

    /// Simple ease-in curve (quadratic).
    private func easeIn(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return t * t
    }

    /// Simple ease-out curve (quadratic).
    private func easeOut(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return 1 - (1 - t) * (1 - t)
    }
}

// MARK: - Fireflies
/// Animated "fireflies" particle layer.
/// Uses TimelineView to update positions and flicker each frame.
/// The random values are stable per index `i` so each firefly keeps its identity.
private struct FirefliesLayer: View {

    // How many fireflies to render.
    let count: Int

    // Screen size used to distribute fireflies across the view.
    let size: CGSize

    // Scale multiplier to keep sizes/drift consistent across devices.
    var scale: CGFloat = 1.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                // Render each firefly at a deterministic base position with animated drift.
                ForEach(0..<count, id: \.self) { i in
                    firefly(i: i, time: t)
                }
            }
        }
    }

    /// Generates a single firefly view with:
    /// - stable base position (seeded by index)
    /// - sinusoidal drift motion
    /// - flickering opacity
    /// - glow/shadow for a luminous look
    private func firefly(i: Int, time t: TimeInterval) -> some View {
        let seed = Double(i) * 97.0

        // Stable base positions (so fireflies don't jump between frames).
        let baseX = stableRand(seed + 1) * size.width
        let baseY = (stableRand(seed + 2) * 0.45 + 0.05) * size.height

        // Smooth drifting motion (sin/cos) with per-firefly speed variation.
        let driftX = sin(t * (0.28 + stableRand(seed + 3) * 0.10) + seed)
            * Double((18 + stableRand(seed + 4) * 22) * scale)

        let driftY = cos(t * (0.24 + stableRand(seed + 5) * 0.10) + seed * 0.7)
            * Double((10 + stableRand(seed + 6) * 18) * scale)

        // Flicker pattern (opacity changes over time).
        let flicker = 0.45 + 0.55 * (0.5 + 0.5 * sin(t * (0.9 + stableRand(seed + 7) * 0.8) + seed * 1.3))

        // Radius and glow size (scaled).
        let r = (2.0 + stableRand(seed + 8) * 2.5) * Double(scale)
        let glow = (6.0 + stableRand(seed + 9) * 10.0) * Double(scale)

        return Circle()
            .fill(Color.green.opacity(0.85))
            .frame(width: r * 2, height: r * 2)
            .position(x: baseX + CGFloat(driftX), y: baseY + CGFloat(driftY))
            .opacity(flicker)
            .shadow(color: .green.opacity(0.9), radius: glow)
            .blur(radius: 0.2 * scale)
    }

    /// Deterministic pseudo-random function (0 → 1) based on a seed.
    /// Using a stable formula ensures each firefly stays consistent across frames.
    private func stableRand(_ x: Double) -> Double {
        let v = sin(x * 12_989.0 + 78.233) * 43_758.5453
        return v - floor(v)
    }
}
