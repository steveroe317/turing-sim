//
//  SimExploreView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/4/25.
//

import SwiftUI

struct SimExploreView: View {
    @Environment(SimModel.self) var simModel

    @Binding var showExploreView: Bool

    var body: some View {
        @Bindable var simModel = simModel

        VStack {
            TuringMapView()
            SimParameterView(label: "F", simParameter: $simModel.f)
                .background(.white.opacity(0.5))
                .cornerRadius(10)
            SimParameterView(label: "K", simParameter: $simModel.k)
                .background(.white.opacity(0.5))
                .cornerRadius(10)
           Button("Close") {
                self.showExploreView.toggle()
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(.gray)
        .cornerRadius(25.0)
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    SimExploreView(showExploreView: $show).environment(SimModel())
}
