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
    
    static func makeMenuItems(from labels: TuringMapLabels) -> [TuringPointItem] {
        labels.labels.keys.enumerated().map { index, point in
            TuringPointItem(id: index, point: point)
        }
        .sorted { $0.point.f > $1.point.f }
    }
    
    let selectMenuItems = makeMenuItems(from: TuringMapLabels())

    @State private var currentSelection: TuringPointItem? = TuringPointItem(id: 1, point: TuringMapPoint(f: 0.055, k: 0.062))

    var body: some View {
        
        VStack {
            Text("Select Simulation Parameters")
                .bold()
            Picker("Select option", selection: $currentSelection) {
                ForEach(selectMenuItems) { option in
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
            currentSelection = selectMenuItems.min(by: { base.distance(to: $0.point) < base.distance(to: $1.point) })
        }
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    SimSelectView(showSelection: $show).environment(SimModel())
}
