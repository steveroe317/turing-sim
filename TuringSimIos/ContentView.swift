//
//  ContentView.swift
//  TuringSimApp
//
//  Created by Steve Roe on 11/28/25.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        ZStack {
            Color(red: 0.6, green: 0.3, blue: 0.2).ignoresSafeArea()
            GeometryReader { geometry in
                CoreView(viewTypeA: .tile, viewTypeB: .none).frame(width: geometry.size.width,
                                 height: geometry.size.height)
            }

        }
        .buttonStyle(SimButtonStyle())
    }
}

#Preview {
    ContentView().preferredColorScheme(.light)
}
