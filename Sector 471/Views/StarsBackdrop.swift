//
//  StarsBackdrop.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 28/08/1447 AH.
//
//  DESCRIPTION (for the team):
//  StarsBackdrop is a reusable background component used across menus and screens.
//  It draws two layered images:
//    1) "emptyspace" as the base background fill.
//    2) "Stars" on top, with a controllable opacity bound to an external ViewModel.
//
//  Twinkle / pulse behavior:
//  - The Stars image uses a Binding<Double> (`starsOpacity`) so each screen can decide
//    how the stars should animate (pulsing, static, etc.).
//  - This view attaches a repeating easeInOut animation to changes in `starsOpacity`.
//    If the parent updates `starsOpacity` over time (ex: StarsPulseViewModel), the Stars
//    layer will smoothly animate between values.
//
//  Layout:
//  - starsOffsetFactor moves the Stars layer downward by a percentage of the screen height.
//    This is useful when the Stars image has a composition that looks better lower/higher.
//  - The frames are slightly oversized to avoid edges showing during scaling/clipping.
//

import SwiftUI

struct StarsBackdrop: View {

    // The size of the container (usually from GeometryReader).
    let size: CGSize

    // Opacity for the Stars layer, controlled by the parent view.
    @Binding var starsOpacity: Double

    // Moves the Stars layer vertically by a factor of the screen height.
    // Example: 0.35 means "move down by 35% of the screen height".
    let starsOffsetFactor: CGFloat

    // Duration used for the repeating opacity animation.
    let pulseDuration: Double

    var body: some View {
        // Convenience values for layout.
        let w = size.width
        let h = size.height

        // Compute how far to shift the Stars image vertically.
        let starsOffset = h * starsOffsetFactor

        ZStack {

            // ===== Base background image =====
            Image("emptyspace")
                .resizable()
                .scaledToFill()
                // Slightly taller than screen to avoid gaps.
                .frame(width: w + 2, height: h + 100)
                .clipped()
                .ignoresSafeArea()

            // ===== Stars overlay image =====
            Image("Stars")
                .resizable()
                .scaledToFill()

                // Opacity is driven by the external binding.
                .opacity(starsOpacity)

                // RepeatForever animation for smooth pulsing when starsOpacity changes.
                // NOTE: This animates the transition whenever starsOpacity updates.
                .animation(
                    .easeInOut(duration: pulseDuration).repeatForever(autoreverses: true),
                    value: starsOpacity
                )

                // Optional vertical offset to reposition the stars composition.
                .offset(y: starsOffset)

                // Slight oversize to avoid edges.
                .frame(width: w + 2, height: h + 2)
                .clipped()
                .ignoresSafeArea()
        }
    }
}
