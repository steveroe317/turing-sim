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
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            SimView()
                .padding()
            HStack {
                Text("Hello, world!")
                    .padding()
                Button("Seed") {
                    simModel.seedRandomly()
                }
                .padding()
                Text("Generation \(simModel.generation)")
                    .padding()
            }
            .padding()
        }
        .environment(simModel)
        .onReceive(timer) { _ in
            simModel.evolve(count: 50)
        }
        .background(Color(.lightGray))
    }
}

#Preview {
    ContentView()
}
