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

import SwiftUI

struct EarthSpaceCrashFlow: View {

    @EnvironmentObject private var pause: PauseController
    @StateObject private var vm = FlowViewModel()

    var body: some View {
        ZStack {

            if vm.step == .universal || vm.universalOpacity > 0.001 {
                UniversalScene(onAdvance: advanceFromUniversalNow)
                    .opacity(vm.universalOpacity)
                    .zIndex(0)
            }

            if vm.step == .earth || vm.earthOpacity > 0.001 {
                EarthScene() // no onAdvance parameter after revert
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

    private func advanceFromUniversalNow() {
        vm.stop()
        vm.step = .earth
        withAnimation(.easeInOut(duration: vm.fadeDuration)) {
            vm.universalOpacity = 0.0
            vm.earthOpacity = 1.0
        }
    }

    private func advanceFromEarthNow() {
        vm.stop()
        vm.step = .space
        withAnimation(.easeInOut(duration: vm.fadeDuration)) {
            vm.earthOpacity = 0.0
            vm.spaceOpacity = 1.0
        }
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
