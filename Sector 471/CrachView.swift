//
//  CrachView.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 22/08/1447 AH.
//
import SwiftUI

struct CrashView: View {
    private let fireflyCount = 35

    @State private var fadeCurrent: String? = nil
    @State private var fadeNext: String? = nil
    @State private var nextOpacity: Double = 0.0
    @State private var showFinalBackground: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                Image("Forest")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                FirefliesLayer(count: fireflyCount, size: geo.size)
                    .allowsHitTesting(false)

                Image("Shuttle")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                AlertLastBreathOverlay()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                if let current = fadeCurrent {
                    Image(current)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        // ✅ .opacity(1.0) removed (no visual change)
                        .zIndex(900)
                }

                if let next = fadeNext {
                    Image(next)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(nextOpacity)
                        .zIndex(901)
                }

                // Final blackout
                if showFinalBackground {
                    Image("Background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .zIndex(999)
                }
            }
            .task { await runFadeSequenceSmooth() }
        }
    }

    private func runFadeSequenceSmooth() async {
        try? await Task.sleep(nanoseconds: 11_000_000_000)

        let sequence = [
            "Fade to Black 1",
            "Fade to Black 2",
            "Fade to Black 3",
            "Fade to Black 4"
        ]

        let stepHold: Double = 1.20
        let forwardCrossfade: Double = 3.95
        let backwardCrossfade: Double = 4.35
        let minSettle: Double = 0.10

        func fadeLevel(from name: String) -> Int {
            let digits = name.compactMap { $0.isNumber ? Int(String($0)) : nil }
            return digits.last ?? 0
        }

        await MainActor.run {
            fadeCurrent = sequence.first
            fadeNext = nil
            nextOpacity = 0.0
        }

        for i in 1..<sequence.count {
            let nextName = sequence[i]

            let currentLevel = fadeCurrent.map(fadeLevel) ?? 0
            let nextLevel = fadeLevel(from: nextName)

            let goingBack = nextLevel < currentLevel
            let crossfade = goingBack ? backwardCrossfade : forwardCrossfade

            let settle = max(minSettle, stepHold - crossfade)

            await MainActor.run {
                fadeNext = nextName
                nextOpacity = 0.0
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: crossfade)) {
                    nextOpacity = 1.0
                }
            }

            try? await Task.sleep(nanoseconds: UInt64(crossfade * 1_000_000_000))

            await MainActor.run {
                fadeCurrent = nextName
                fadeNext = nil
                nextOpacity = 0.0
            }

            if settle > 0 {
                try? await Task.sleep(nanoseconds: UInt64(settle * 1_000_000_000))
            }
        }

        await MainActor.run {
            fadeCurrent = nil
            fadeNext = nil
            nextOpacity = 0.0
            showFinalBackground = true
        }
    }
}

private struct AlertLastBreathOverlay: View {
    @State private var startTime: Date = Date()

    private let glowAmount: Double = 2.25
    private let glowDistance: CGFloat = 65
    private let glowSoftness: CGFloat = 68

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSince(startTime)

            let blipPhaseEnd: Double = 6.5

            let lastBreathStart: Double = blipPhaseEnd
            let lastBreathDuration: Double = 4.2
            let endTime = lastBreathStart + lastBreathDuration

            let alertOpacity: Double = {
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

                if t < endTime {
                    let u = (t - lastBreathStart) / lastBreathDuration
                    let surgeEnd = 0.18
                    let holdEnd  = 0.52

                    let base: Double
                    if u < surgeEnd { base = easeOut(u / surgeEnd) }
                    else if u < holdEnd { base = 1.0 }
                    else {
                        let v = (u - holdEnd) / (1.0 - holdEnd)
                        base = 1.0 - easeIn(v)
                    }

                    let dyingBoost = (u < holdEnd) ? 0.25 : (0.25 + (u - holdEnd) * 0.9)

                    let flicker =
                        1.0
                        - dyingBoost * 0.35 * (0.5 + 0.5 * sin((t - lastBreathStart) * 18.0))
                        - dyingBoost * 0.18 * (0.5 + 0.5 * sin((t - lastBreathStart) * 41.0 + 1.4))

                    let snapZone = max(0.0, (u - 0.80) / 0.20)
                    let snaps = 1.0 - snapZone * 0.45 * (0.5 + 0.5 * sin((t - lastBreathStart) * 55.0))

                    return max(0.0, min(1.0, base * flicker * snaps))
                }

                return 0.0
            }()

            let glowOpacity = min(1.0, alertOpacity * glowAmount)

            ZStack {
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

                Image("Alert only")
                    .resizable()
                    .scaledToFill()
                    .opacity(alertOpacity)
                    .brightness(alertOpacity > 0.01 ? 0.10 : 0.0)
            }
        }
        .onAppear { startTime = Date() }
    }

    private func easeIn(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return t * t
    }

    private func easeOut(_ x: Double) -> Double {
        let t = max(0, min(1, x))
        return 1 - (1 - t) * (1 - t)
    }
}

private struct FirefliesLayer: View {
    let count: Int
    let size: CGSize

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    firefly(i: i, time: t)
                }
            }
        }
    }

    private func firefly(i: Int, time t: TimeInterval) -> some View {
        let seed = Double(i) * 97.0
        let baseX = stableRand(seed + 1) * size.width
        let baseY = (stableRand(seed + 2) * 0.45 + 0.05) * size.height

        let driftX = sin(t * (0.28 + stableRand(seed + 3) * 0.10) + seed) * (18 + stableRand(seed + 4) * 22)
        let driftY = cos(t * (0.24 + stableRand(seed + 5) * 0.10) + seed * 0.7) * (10 + stableRand(seed + 6) * 18)

        let flicker = 0.45 + 0.55 * (0.5 + 0.5 * sin(t * (0.9 + stableRand(seed + 7) * 0.8) + seed * 1.3))

        let r = 2.0 + stableRand(seed + 8) * 2.5
        let glow = 6.0 + stableRand(seed + 9) * 10.0

        return Circle()
            .fill(Color.green.opacity(0.85))
            .frame(width: r * 2, height: r * 2)
            .position(x: baseX + driftX, y: baseY + driftY)
            .opacity(flicker)
            .shadow(color: .green.opacity(0.9), radius: glow)
            .blur(radius: 0.2)
    }

    private func stableRand(_ x: Double) -> Double {
        let v = sin(x * 12_989.0 + 78.233) * 43_758.5453
        return v - floor(v)
    }
}

#Preview ("Landscape Preview", traits: .landscapeLeft){
    CrashView()
}

