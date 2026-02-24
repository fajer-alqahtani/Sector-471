//
//  SpaceToCrashFlow.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  EarthSpaceCrashFlow is the main “cinematic flow” container that plays the story scenes in order.
//  It is responsible for:
//  - Showing the correct scene (Universal → Earth → Space → Crash) based on FlowViewModel.Step
//  - Crossfading between scenes using per-scene opacity values from FlowViewModel
//  - Providing a pause button overlay that can open the pause menu (PuseMenu)
//
//  How scene switching works:
//  - FlowViewModel owns `step` and the opacity values for each scene.
//  - Each scene is conditionally rendered when it is the current step OR when its opacity
//    is still above a small threshold (so fade-out can complete smoothly).
//  - SpaceScene receives a callback (onFinish) which triggers vm.startCrashTransition()
//    to move from Space → Crash when the space timeline ends.
//
//  Pause behavior:
//  - Tapping the pause button sets vm.isPaused = true.
//  - When paused, PuseMenu is shown as a full overlay.
//  - Continue calls vm.resume() to hide the pause menu.
//  NOTE: In this file, pausing currently controls UI visibility only.
//  It does NOT stop the FlowViewModel’s internal timing task unless the scenes handle it separately.
//

import SwiftUI

struct EarthSpaceCrashFlow: View {

    // ViewModel that controls which scene is active and manages crossfade timing.
    @StateObject private var vm = FlowViewModel()

    var body: some View {
        ZStack {

            // ===== Universal Scene =====
            // Render if it's the active step OR if opacity is still fading out.
            if vm.step == .universal || vm.universalOpacity > 0.001 {
                UniversalScene()
                    .opacity(vm.universalOpacity)
                    .zIndex(0)
            }

            // ===== Earth Scene =====
            if vm.step == .earth || vm.earthOpacity > 0.001 {
                EarthScene()
                    .opacity(vm.earthOpacity)
                    .zIndex(1)
            }

            // ===== Space Scene =====
            // When Space finishes, it triggers vm.startCrashTransition() to move to Crash.
            if vm.step == .space || vm.spaceOpacity > 0.001 {
                SpaceScene(onFinish: vm.startCrashTransition)
                    .opacity(vm.spaceOpacity)
                    .zIndex(2)
            }

            // ===== Crash Scene =====
            if vm.step == .crash || vm.crashOpacity > 0.001 {
                CrashView()
                    .opacity(vm.crashOpacity)
                    .zIndex(3)
            }

            // ===== Pause button overlay =====
            // Always visible on top-left (positioned using large leading padding for your layout).
            Button {
                vm.pause()
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
            // Manual positioning (tuned for your base layout).
            .padding(.leading, 1306)
            .padding(.top, 12)
            .zIndex(10_000)

            // ===== Pause menu overlay =====
            // Shown only when vm.isPaused is true.
            if vm.isPaused {
                PuseMenu(onContinue: { vm.resume() })
                    .transition(.opacity)
                    .zIndex(20_000)
            }
        }

        // Keep interactions enabled for this container.
        .allowsHitTesting(true)

        // Start and stop the FlowViewModel task with the lifecycle of this view.
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EarthSpaceCrashFlow()
    }
}
