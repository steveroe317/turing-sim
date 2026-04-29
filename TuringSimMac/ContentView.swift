//
//  ContentView.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

import Combine
import SwiftUI

struct ContentView: View {

    var body: some View {
        ZStack {
            (Color(red: 0.660, green: 0.385, blue: 0.270))
            CoreView(viewTypeA: .TILE, viewTypeB: .NONE)
                .buttonStyle(SimButtonStyle())
        }
    }
}

#Preview {
    ContentView()
}
