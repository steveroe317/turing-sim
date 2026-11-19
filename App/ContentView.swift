//
//  ContentView.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

import SwiftUI

/// Root view shared by the iOS, iPadOS, and macOS builds of TuringSim.
struct ContentView: View {

    /// Window background color. The platforms have historically used
    /// slightly different shades; keep them until a single color is chosen.
    private static let backgroundColor: Color = {
#if os(macOS)
        Color(red: 0.660, green: 0.385, blue: 0.270)
#else
        Color(red: 0.6, green: 0.3, blue: 0.2)
#endif
    }()

    var body: some View {
        ZStack {
            Self.backgroundColor.ignoresSafeArea()
            CoreView(viewTypeA: .tile, viewTypeB: .none)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(SimButtonStyle())
    }
}

#Preview {
    ContentView().preferredColorScheme(.light)
}
