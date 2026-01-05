//
//  SimSelectView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct SimSelectView: View {
    @Binding var showSelection: Bool

    @Environment(SimModel.self) var simModel
    @Environment(TuringMapLabels.self) var mapLabels
    @Environment(\.colorScheme) var colorScheme

    struct TuringPointItem: Identifiable, Hashable {
        let id: Int
        let F: Double
        let K: Double

        func label(f: Double, k: Double, mapLabels: TuringMapLabels) -> String {
            return mapLabels.getLabel(forPoint: TuringMapPoint(f: f, k: k)) ?? ""
        }
    }

    let parameterOptions: [TuringPointItem] = [
        TuringPointItem(id: 1, F: 0.055, K: 0.062),
        TuringPointItem(id: 2, F: 0.042, K: 0.059),
        TuringPointItem(id: 3, F: 0.038, K: 0.061),
        TuringPointItem(id: 4, F: 0.034, K: 0.061),
        TuringPointItem(id: 5, F: 0.034, K: 0.063),
        TuringPointItem(id: 6, F: 0.026, K: 0.052),
        TuringPointItem(id: 7, F: 0.022, K: 0.050,),
        TuringPointItem(id: 8, F: 0.026, K: 0.056),
        TuringPointItem(id: 9, F: 0.022, K: 0.048),
        TuringPointItem(id: 10, F: 0.016, K: 0.048),
        TuringPointItem(id: 11, F: 0.014, K: 0.040),
        TuringPointItem(id: 12, F: 0.014, K: 0.050),
        TuringPointItem(id: 13, F: 0.014, K: 0.053),
    ]

    @State private var currentSelection: TuringPointItem? = TuringPointItem(id: 1, F: 0.055, K: 0.062)

    var body: some View {
        
        VStack {
            Text("Select Simulation Parameters")
                .bold(true)
            Picker("Select option", selection: $currentSelection) {
                ForEach(parameterOptions) { option in
                    Text(option.label(f: option.F, k: option.K, mapLabels: mapLabels)).tag(
                        option as TuringPointItem?
                    )
                }
            }
            #if os(iOS)
                .pickerStyle(WheelPickerStyle())
            #endif
            .background(colorScheme == .light ? Color(Color.skyBlue) : Color.darkSkyBlue)
            .foregroundColor(colorScheme == .light ? Color(.darkGray) : Color(.lightGray))
            .accentColor(colorScheme == .light ?  .black : .white)
            .cornerRadius(10.0)
            .padding(.horizontal, 20.0)
            .padding(.vertical, 10.0)
            HStack {
                Spacer()
                Button("Confirm", role: .confirm) {
                    showSelection = false
                    if let currentSelection = currentSelection {
                        if currentSelection.F != 0
                            && currentSelection.F != 0
                        {
                            simModel.f = currentSelection.F
                            simModel.k = currentSelection.K
                        }
                    }
                }
                Spacer()
                Button("Cancel", role: .cancel) {
                    showSelection = false
                    print("no selection")
                }
                Spacer()
            }
        }
        .padding(20.0)
        .background(.black.opacity(0.5))
        .cornerRadius(25.0)
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    SimSelectView(showSelection: $show).environment(SimModel())
}
