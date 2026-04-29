//
//  CoreView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct CoreView: View {
    
    let viewTypeA: SimViewType
    let viewTypeB: SimViewType

    @State private var simModel = SimModel()
    @State private var mapLabels = TuringMapLabels()
    @State private var showSelectView: Bool = false
    @State private var showExploreView: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Turing Patterns")
                .font(Font.largeTitle)
                .padding(4)
                .colorEffect(ShaderLibrary.passthrough())
            SimInformationView()
                .padding(4)
            ZStack(alignment: .center) {
                HStack {
                    // Always present at least one simulation view.
                    switch viewTypeA {
                    case .TILE:
                        SimTileView()
                    case .SHADER:
                        SimShaderView()
                    case .SMOOTH_SHADER:
                        SimSmoothShaderView()
                    case .NONE:
                        SimTileView()
                    }
                    // Optionally present a second simulation view for comparison.
                    if viewTypeB == .TILE {
                        SimTileView()
                    } else if viewTypeB == .SHADER {
                        SimShaderView()
                    } else if viewTypeB == .SMOOTH_SHADER {
                        SimSmoothShaderView()
                    }
                }
                .background(.white.opacity(0.3))
                .padding(8)
                
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
            .padding(4)
            ViewThatFits {
                HStack(alignment: .lastTextBaseline) {
                    SimControlView(
                        showSelectView: $showSelectView,
                        showExploreView: $showExploreView
                    )
                    .padding(4)
                }
                VStack {
                    SimControlView(
                        showSelectView: $showSelectView,
                        showExploreView: $showExploreView
                    )
                    .padding(4)
                }
            }
        }
        .environment(simModel)
        .environment(mapLabels)
    }
}

#Preview {
    CoreView(viewTypeA: .TILE, viewTypeB: .NONE).environment(SimModel())
}
