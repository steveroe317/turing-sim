//
//  SimInformationView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/4/25.
//

import SwiftUI

struct SimInformationView: View {
    @Environment(SimModel.self) var simModel

    var body: some View {
        let minInfoWidth = CGFloat(160)
        let minRateWidth = CGFloat(80)
        ViewThatFits {
            HStack(alignment: .lastTextBaseline) {
                Text(
                    String(
                        format: "F %.3f, K %.3f",
                        simModel.f,
                        simModel.k
                    )
                )
                .frame(minWidth: minInfoWidth, alignment: .leading)
                .padding(4)
                Text("Generation \(simModel.generation)")
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
                Text("Rate \(Int(simModel.generationRate.rounded()))")
                    .frame(minWidth: minRateWidth, alignment: .leading)
                    .padding(4)
            }
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text(
                        String(
                            format: "F %.3f, K %.3f",
                            simModel.f,
                            simModel.k
                        )
                    )
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
                    Text("Generation \(simModel.generation)")
                        .frame(minWidth: minInfoWidth, alignment: .leading)
                        .padding(4)
                }
                Text("Rate \(Int(simModel.generationRate.rounded()))")
                    .frame(minWidth: minRateWidth, alignment: .leading)
                    .padding(4)
            }
            VStack {
                Text(
                    String(
                        format: "F %.3f, K %.3f",
                        simModel.f,
                        simModel.k
                    )
                )
                .frame(minWidth: minInfoWidth, alignment: .leading)
                .padding(4)
                Text("Generation \(simModel.generation)")
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
                Text("Rate \(Int(simModel.generationRate.rounded()))")
                    .frame(minWidth: minRateWidth, alignment: .leading)
                    .padding(4)
            }
        }
    }
}

#Preview {
    SimInformationView().environment(SimModel())
}
