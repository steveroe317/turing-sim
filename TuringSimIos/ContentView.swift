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
            CoreView(viewTypeA: .tile, viewTypeB: .none)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(SimButtonStyle())
    }
}

#Preview {
    ContentView().preferredColorScheme(.light)
}
