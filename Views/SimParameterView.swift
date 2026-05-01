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
        ViewThatFits (in: .horizontal) {
            HStack {
                Spacer()
                Stepper(
                    "\(label): \(simParameter.formatted(.number.precision(.fractionLength(3))))",
                    value: $simParameter,
                    in: 0.0...0.1,
                    step: 0.001
                )
                .frame(minWidth: 180)
                Spacer()
                Slider(value: $simParameter, in: 0.0...0.1, step: 0.001)
                    .frame(minWidth: 120, maxWidth: 180)
                Spacer()
            }
            .padding(4)
            VStack {
                Spacer()
                Stepper(
                    "\(label): \(simParameter.formatted(.number.precision(.fractionLength(3))))",
                    value: $simParameter,
                    in: 0.0...0.1,
                    step: 0.001
                )
                .frame(minWidth: 180, maxWidth: 240)
                Spacer()
                Slider(value: $simParameter, in: 0.0...0.1, step: 0.001)
                    .frame(minWidth: 180, maxWidth: 240)
                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    @Previewable @State var parameter: Double = 0.1
    let text = "K"
    SimParameterView(label: text, simParameter: $parameter)
}
