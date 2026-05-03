//
//  SimSelectView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct SimSelectView: View {
    @Binding var showSelection: Bool

    @Environment(SimModel.self) var simModel
    @Environment(TuringMapLabels.self) var mapLabels
    
    @State private var pickerHeight: CGFloat = 0

    func makeMenuItems(from labels: TuringMapLabels) -> [TuringPointItem] {
        labels.labels.keys.enumerated().map { index, point in
            TuringPointItem(id: index, point: point)
        }
        .sorted { ($0.point.f, $0.point.k) > ($1.point.f, $1.point.k) }
    }
    
    @State private var isLoading: Bool = true
    @State private var currentSelection: TuringPointItem?

    var body: some View {
        let selectMenuItems = makeMenuItems(from: mapLabels)

        VStack {
            Text("Select Simulation Parameters")
                .bold()
            ZStack {
                if isLoading{
                    ProgressView()
                        .frame(height: pickerHeight)
                } else {
                    SimSelectPicker(menuItems: selectMenuItems, selection: $currentSelection)
                }
                // Measure hidden picker height to size the placeholder ProgressView.
                SimSelectPicker(menuItems: selectMenuItems, selection: $currentSelection)
                    .hidden()
                    .background(GeometryReader { geo in
                        Color.clear
                            .preference(key: HeightKey.self, value: geo.size.height)
                    })
            }
            .onPreferenceChange(HeightKey.self) { height in
                pickerHeight = height
            }
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
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    SimSelectView(showSelection: $show).environment(SimModel())
}
