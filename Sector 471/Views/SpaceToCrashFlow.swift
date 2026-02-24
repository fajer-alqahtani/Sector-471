//
//  SpaceToCrashFlow.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//
import SwiftUI

struct EarthSpaceCrashFlow: View {

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
                    .padding(12)
                    .background(.purple.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 1306)
            .padding(.top, 12)
            .zIndex(10_000)

            if vm.isPaused {
                PuseMenu(onContinue: { vm.resume() })
                    .transition(.opacity)
                    .zIndex(20_000)
            }
        }
        
        .allowsHitTesting(true)
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

#Preview {
    NavigationStack {
        EarthSpaceCrashFlow()
    }
}
