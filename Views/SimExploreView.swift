//
//  SimExploreView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/4/25.
//

import SwiftUI

struct SimExploreView: View {
    let mapScale: CGFloat
    @Environment(SimModel.self) var simModel

    @Binding var showExploreView: Bool

    @State var f: Double
    @State var k: Double

    init(mapScale: CGFloat, showExploreView: Binding<Bool>, initialF: Double, initialK: Double) {
        self.mapScale = mapScale
        self._showExploreView = showExploreView
        self._f = State(initialValue: initialF)
        self._k = State(initialValue: initialK)
    }

    var body: some View {
        @Bindable var simModel = simModel

        VStack {
            TuringMapView(scale: mapScale, f: $f, k: $k)
            SimParameterView(label: "F", simParameter: $f)
                .background(.white.opacity(0.5))
                .frame(maxWidth: 380)
                .clipShape(.rect(cornerRadius: 10))
            SimParameterView(label: "K", simParameter: $k)
                .background(.white.opacity(0.5))
                .frame(maxWidth: 380)
                .clipShape(.rect(cornerRadius: 10))
            HStack {
                Button("Confirm", role: .confirm) {
                    self.showExploreView.toggle()
                    simModel.f = f
                    simModel.k = k
                }
                Button("Cancel", role: .cancel) {
                    self.showExploreView.toggle()
                }
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(.gray)
        .clipShape(.rect(cornerRadius: 25.0))
    }
}


#Preview {
    @Previewable @State var show: Bool = true
    SimExploreView(mapScale: 300, showExploreView: $show, initialF: 0.055, initialK: 0.062)
        .environment(SimModel())
}
