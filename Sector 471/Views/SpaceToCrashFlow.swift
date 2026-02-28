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

    @EnvironmentObject private var pause: PauseController
    @StateObject private var vm = FlowViewModel()

    var body: some View {
        ZStack {

            if vm.step == .universal || vm.universalOpacity > 0.001 {
                UniversalScene()
                    .opacity(vm.universalOpacity)
                    .zIndex(0)
            }

            if vm.step == .earth || vm.earthOpacity > 0.001 {
                EarthScene()
                    .opacity(vm.earthOpacity)
                    .zIndex(1)
            }

            if vm.step == .space || vm.spaceOpacity > 0.001 {
                SpaceScene(onFinish: vm.startCrashTransition)
                    .opacity(vm.spaceOpacity)
                    .zIndex(2)
            }

            if vm.step == .crash || vm.crashOpacity > 0.001 {
                CrashView()
                    .opacity(vm.crashOpacity)
                    .zIndex(3)
            }

            Button {
                vm.pause()
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(.purple.opacity(0.09))
                    .clipShape(RoundedRectangle(cornerRadius: 162, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.trailing, 26)
            .padding(.top, 22)
            .zIndex(10_000)

            if vm.isPaused {
                PuseMenu(onContinue: { vm.resume() })
                    .transition(.opacity)
                    .zIndex(20_000)
            }
        }
        .allowsHitTesting(true)
        .onAppear {
            vm.configure(pause: pause)
            vm.start()
        }
        .onDisappear { vm.stop() }
    }
}

#Preview {
    NavigationStack {
        EarthSpaceCrashFlow()
            .environmentObject(PauseController())
            .environmentObject(AppAccessibilitySettings())
            .environmentObject(ScriptStore.shared)           
    }
}
