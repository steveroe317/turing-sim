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
        let point: TuringMapPoint

        func label(point: TuringMapPoint, mapLabels: TuringMapLabels) -> String {
            return mapLabels.getLabel(forPoint: point) ?? ""
        }
    }

    let menuItems: [TuringPointItem] = [
        TuringPointItem(id: 1, point: TuringMapPoint(f: 0.055, k: 0.062)),
        TuringPointItem(id: 2, point: TuringMapPoint(f: 0.042, k: 0.059)),
        TuringPointItem(id: 3, point: TuringMapPoint(f: 0.038, k: 0.061)),
        TuringPointItem(id: 4, point: TuringMapPoint(f: 0.034, k: 0.061)),
        TuringPointItem(id: 5, point: TuringMapPoint(f: 0.034, k: 0.063)),
        TuringPointItem(id: 6, point: TuringMapPoint(f: 0.026, k: 0.052)),
        TuringPointItem(id: 7, point: TuringMapPoint(f: 0.022, k: 0.050)),
        TuringPointItem(id: 8, point: TuringMapPoint(f: 0.026, k: 0.056)),
        TuringPointItem(id: 9, point: TuringMapPoint(f: 0.022, k: 0.048)),
        TuringPointItem(id: 10, point: TuringMapPoint(f: 0.016, k: 0.048)),
        TuringPointItem(id: 11, point: TuringMapPoint(f: 0.014, k: 0.040)),
        TuringPointItem(id: 12, point: TuringMapPoint(f: 0.014, k: 0.050)),
        TuringPointItem(id: 13, point: TuringMapPoint(f: 0.014, k: 0.053)),
    ]

    @State private var currentSelection: TuringPointItem? = TuringPointItem(id: 1, point: TuringMapPoint(f: 0.055, k: 0.062))

    var body: some View {
        
        VStack {
            Text("Select Simulation Parameters")
                .bold()
            Picker("Select option", selection: $currentSelection) {
                ForEach(menuItems) { option in
                    Text(option.label(point: option.point, mapLabels: mapLabels)).tag(
                        option as TuringPointItem?
                    )
                }
            }
            #if os(iOS)
                .pickerStyle(WheelPickerStyle())
            #endif
            .background(colorScheme == .light ? Color(Color.skyBlue) : Color.darkSkyBlue)
            .foregroundColor(colorScheme == .light ? Color(.darkGray) : Color(.lightGray))
            .tint(colorScheme == .light ?  .black : .white)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal, 20.0)
            .padding(.vertical, 10.0)
            HStack {
                Spacer()
                Button("Confirm", role: .confirm) {
                    showSelection = false
                    if let currentSelection = currentSelection {
                        simModel.f = currentSelection.point.f
                        simModel.k = currentSelection.point.k
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
        .clipShape(.rect(cornerRadius: 25))
        .task {
            let base = TuringMapPoint(f: simModel.f, k: simModel.k)
            currentSelection = menuItems.min(by: { base.distance(to: $0.point) < base.distance(to: $1.point) })
        }
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    SimSelectView(showSelection: $show).environment(SimModel())
}
