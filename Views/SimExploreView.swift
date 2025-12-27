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
    
    @State var f : Double = 0.05
    @State var k : Double = 0.05
    
    var body: some View {
        @Bindable var simModel = simModel

        VStack {
            TuringMapView(f: $f, k: $k)
            SimParameterView(label: "F", simParameter: $f)
                .background(.white.opacity(0.5))
                .cornerRadius(10)
            SimParameterView(label: "K", simParameter: $k)
                .background(.white.opacity(0.5))
                .cornerRadius(10)
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
        .cornerRadius(25.0)
        .onAppear {
            f = simModel.f
            k = simModel.k
        }
    }
}


#Preview {
    @Previewable @State var show: Bool = true
    SimExploreView(showExploreView: $show).environment(SimModel())
}
