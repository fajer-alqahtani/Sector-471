//
//  SpaceToCrashFlow.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//

import SwiftUI

struct EarthSpaceCrashFlow: View {
    private enum Step { case earth, space, crash }

    @State private var step: Step = .earth

    @State private var earthOpacity: Double = 1.0
    @State private var spaceOpacity: Double = 0.0
    @State private var crashOpacity: Double = 0.0

    private let fadeDuration: Double = 1.2
    private let earthHoldSeconds: Double = 4.0

    // ✅ pause overlay state
    @State private var isPaused = false

    var body: some View {
        ZStack {
            if step == .earth || earthOpacity > 0.001 {
                EarthScene()
                    .opacity(earthOpacity)
                    .zIndex(1)
            }

            if step == .space || spaceOpacity > 0.001 {
                SpaceScene(onFinish: startCrashTransition)
                    .opacity(spaceOpacity)
                    .zIndex(2)
            }

            if step == .crash || crashOpacity > 0.001 {
                CrashView()
                    .opacity(crashOpacity)
                    .zIndex(3)
            }

            // ✅ Pause button always visible
            Button {
                isPaused = true
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.purple.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 1306)
            .padding(.top, 12)
            .zIndex(10_000)

            // ✅ Pause menu overlay (same screen)
            if isPaused {
                PuseMenu(onContinue: { isPaused = false })
                    .transition(.opacity)
                    .zIndex(20_000)
            }
        }
        // ✅ prevent touches reaching the scenes while paused
        .allowsHitTesting(!isPaused ? true : true)
        .task { await startEarthThenSpace() }
    }

    private func startEarthThenSpace() async {
        await MainActor.run {
            step = .earth
            earthOpacity = 1.0
            spaceOpacity = 0.0
            crashOpacity = 0.0
        }

        try? await Task.sleep(nanoseconds: UInt64(earthHoldSeconds * 1_000_000_000))

        await MainActor.run {
            step = .space
            withAnimation(.easeInOut(duration: fadeDuration)) {
                earthOpacity = 0.0
                spaceOpacity = 1.0
            }
        }
    }

    private func startCrashTransition() {
        guard step != .crash else { return }

        step = .crash
        crashOpacity = 0.0

        withAnimation(.easeInOut(duration: fadeDuration)) {
            spaceOpacity = 0.0
            crashOpacity = 1.0
        }
    }
}


#Preview {
    NavigationStack {
        EarthSpaceCrashFlow()
    }
}

