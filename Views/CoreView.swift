//
//  CoreView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct CoreView: View {

    @State private var simModel = SimModel()
    @State private var mapLabels = TuringMapLabels()
    @State private var showSelectView: Bool = false
    @State private var showExploreView: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Turing Patterns")
                .font(Font.largeTitle)
            ZStack(alignment: .center) {
                SimView()
                if showSelectView {
                    SimSelectView(showSelection: $showSelectView)
                        .frame(maxWidth: 380, maxHeight: 340)
                } else if showExploreView {
                    ViewThatFits {
                        SimExploreView(mapScale: 800, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 800, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 700, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 600, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 500, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 400, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                        SimExploreView(mapScale: 300, showExploreView: $showExploreView)
                            .aspectRatio(1.0, contentMode: .fit)
                    }
                }
            }
            .padding(20)
            ViewThatFits {
                HStack(alignment: .lastTextBaseline) {
                    SimControlView(
                        showSelectView: $showSelectView,
                        showExploreView: $showExploreView
                    )
                    .padding(4)
                    SimInformationView()
                        .padding(4)
                }
                VStack {
                    SimControlView(
                        showSelectView: $showSelectView,
                        showExploreView: $showExploreView
                    )
                    .padding(4)
                    SimInformationView()
                        .padding(4)
                }
            }
        }
        .environment(simModel)
        .environment(mapLabels)
    }
}

#Preview {
    CoreView().environment(SimModel())
}
