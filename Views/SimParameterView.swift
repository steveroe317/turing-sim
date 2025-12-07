//
//  SimParameterView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct SimParameterView: View {
    var label: String
    @Binding var simParameter: Double

    var body: some View {
        HStack {
            Stepper(
                String(format: "\(label): %.3f", simParameter),
                value: $simParameter,
                in: 0.0...0.2,
                step: 0.001
            )
            .frame(minWidth: 180)
            .padding(4)
            Slider(value: $simParameter, in: 0.0...0.2, step: 0.001)
                .frame(minWidth: 120, maxWidth: 180)
                .padding(4)
        }
    }
}

#Preview {
    @Previewable @State var parameter: Double = 0.1
    let text = "K"
    SimParameterView(label: text, simParameter: $parameter)
}
