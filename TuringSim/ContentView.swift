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
            VStack(alignment: .center) {
                Text("Turing Pattern Evolution")
                    .font(Font.largeTitle)
                    .padding(8)
                SimView()
                    .padding(8)
                HStack(alignment: .lastTextBaseline) {
                    if simModel.isRunning() {
                        Button("Pause") {
                            simModel.pause()
                        }
                        .padding(8)
                    } else {
                        Button("Start") {
                            simModel.start()
                        }
                        .padding(8)
                    }
                    Button("Seed") {
                        simModel.seedRandomly()
                    }
                    .padding(8)
                    Button("Reset") {
                        simModel.reset()
                    }
                    .padding(8)
                    Text("Generation \(simModel.generation)")
                        .padding(8)
                }
                .padding(8)
            }
            .environment(simModel)
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    ContentView()
}
