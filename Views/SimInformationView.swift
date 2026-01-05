//
//  SimInformationView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/4/25.
//

import SwiftUI

struct SimInformationView: View {
    @Environment(SimModel.self) var simModel
    @Environment(TuringMapLabels.self) var mapLabels

    var body: some View {
        let minInfoWidth = CGFloat(120)
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
                Text(mapLabels.getLabel(forPoint: .init(f: simModel.f, k: simModel.k)) ?? "")
                    .frame(minWidth: minInfoWidth, alignment: .center)
                    .padding(4)
                Text("Generation \(simModel.generation)")
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
                Text("\(Int(simModel.generationRate.rounded()))/sec")
                    .frame(minWidth: minInfoWidth, alignment: .trailing)
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
                    Text(mapLabels.getLabel(forPoint: .init(f: simModel.f, k: simModel.k)) ?? "")
                        .frame(minWidth: minInfoWidth, alignment: .trailing)
                        .padding(4)
                }
                HStack(alignment: .lastTextBaseline) {
                    Text("Generation \(simModel.generation)")
                        .frame(minWidth: minInfoWidth, alignment: .leading)
                        .padding(4)
                    Text("\(Int(simModel.generationRate.rounded()))/sec")
                        .frame(minWidth: minInfoWidth, alignment: .trailing)
                        .padding(4)
                }
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
                Text(mapLabels.getLabel(forPoint: .init(f: simModel.f, k: simModel.k)) ?? "")
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
                Text("\(Int(simModel.generationRate.rounded()))/sec")
                    .frame(minWidth: minInfoWidth, alignment: .leading)
                    .padding(4)
            }

        }
    }
}

#Preview {
    SimInformationView().environment(SimModel())
}
