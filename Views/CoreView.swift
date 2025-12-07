//
//  CoreView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct CoreView: View {
    @Environment(SimModel.self) var simModel

    @State private var showSelectView: Bool = false
    @State private var showExploreView: Bool = false

    var body: some View {
        @Bindable var simModel = simModel

        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                Text("Turing Patterns")
                    .font(Font.largeTitle)
                SimView()
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
            .padding(4)
            if showSelectView {
                SimSelectView(showSelection: $showSelectView)
                    .frame(maxWidth: 380, maxHeight: 340)
            } else if showExploreView {
                Spacer()
                SimExploreView(showExploreView: $showExploreView)
                    .frame(maxWidth: 380, maxHeight: 240)
            }
        }
    }
}

#Preview {
    CoreView().environment(SimModel())
}
