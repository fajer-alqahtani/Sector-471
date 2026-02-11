//
//  StarsBackdrop.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 28/08/1447 AH.
//

import SwiftUI

struct StarsBackdrop: View {
    let size: CGSize
    @Binding var starsOpacity: Double

    let starsOffsetFactor: CGFloat
    let pulseDuration: Double

    var body: some View {
        let w = size.width
        let h = size.height
        let starsOffset = h * starsOffsetFactor

        ZStack {
            Image("emptyspace")
                .resizable()
                .scaledToFill()
                .frame(width: w + 2, height: h + 100)
                .clipped()
                .ignoresSafeArea()

            Image("Stars")
                .resizable()
                .scaledToFill()
                .opacity(starsOpacity)
                .animation(
                    .easeInOut(duration: pulseDuration).repeatForever(autoreverses: true),
                    value: starsOpacity
                )
                .offset(y: starsOffset)
                .frame(width: w + 2, height: h + 2)
                .clipped()
                .ignoresSafeArea()
        }
    }
}
