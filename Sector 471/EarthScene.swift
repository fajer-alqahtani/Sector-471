//
//  EarthScene.swift
//  Sector 471
//
//  Created by Rahaf Alhammadi on 23/08/1447 AH.
//

import SwiftUI

struct EarthScene: View {
    @State private var earthGrow = false

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // Background
                Image("emptyspace")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w + 2, height: h + 2)
                    .clipped()
                    .ignoresSafeArea()

                // Earth (center)
                Image("Earth and moon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 1200)
                    .position(x: w / 2, y: h / 2)

                // Moon (center, slightly offset so it’s visible)

            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    EarthScene()
}
