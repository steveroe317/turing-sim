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
        VStack(alignment: .center) {
            Text("Turing Pattern Evolution")
                .font(Font.largeTitle)
                .padding(8)
            SimView()
                .padding(8)
            HStack(alignment: .lastTextBaseline) {
                Button("Seed") {
                    simModel.seedRandomly()
                }
                .padding(8)
                Text("Generation \(simModel.generation)")
                    .padding(8)
            }
            .padding(8)
        }
        .environment(simModel)
        .background(Color(.lightGray))
    }
}

#Preview {
    ContentView()
}
