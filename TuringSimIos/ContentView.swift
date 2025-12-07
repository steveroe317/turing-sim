//
//  ContentView.swift
//  TuringSimApp
//
//  Created by Steve Roe on 11/28/25.
//

import SwiftUI

struct ContentView: View {

    @State private var simModel = SimModel()

    var body: some View {
        ZStack {
            Color(red: 0.6, green: 0.3, blue: 0.2).edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                CoreView().frame(width: geometry.size.width,
                                 height: geometry.size.height)
            }

        }
        .environment(simModel)
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ContentView().preferredColorScheme(.light)
}
