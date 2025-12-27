//
//  ContentView.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

import Combine
import SwiftUI

struct ContentView: View {

    @State private var simModel = SimModel()

    var body: some View {
        CoreView()
            .environment(simModel)
            .background(Color(red: 0.660, green: 0.385, blue: 0.270))
            .buttonStyle(SimButtonStyle())
    }
}

#Preview {
    ContentView()
}
