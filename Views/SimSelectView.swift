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
    @Environment(\.colorScheme) var colorScheme

    struct ParameterOption: Identifiable, Hashable {
        let id: Int
        let F: Double
        let K: Double
        let comment: String

        func description() -> String {
            if F != 0.0 && K != 0.0 {
                return "\(comment) F: \(F), K: \(K)"
            }
            return comment
        }
    }

    let parameterOptions: [ParameterOption] = [
        ParameterOption(id: 1, F: 0.055, K: 0.062, comment: "Cerebellum"),
        ParameterOption(id: 2, F: 0.042, K: 0.059, comment: "Lace"),
        ParameterOption(id: 3, F: 0.038, K: 0.061, comment: "Tiles"),
        ParameterOption(id: 4, F: 0.034, K: 0.061, comment: "Strings"),
        ParameterOption(id: 5, F: 0.034, K: 0.063, comment: "Mitosis"),
        ParameterOption(id: 6, F: 0.026, K: 0.052, comment: "Mandala"),
        ParameterOption(id: 7, F: 0.022, K: 0.050, comment: "Shimmer"),
        ParameterOption(id: 8, F: 0.026, K: 0.056, comment: "Evolution"),
        ParameterOption(id: 9, F: 0.022, K: 0.048, comment: "Tunnel"),
        ParameterOption(id: 10, F: 0.016, K: 0.048, comment: "Reflections"),
        ParameterOption(id: 11, F: 0.014, K: 0.040, comment: "Fog"),
        ParameterOption(id: 12, F: 0.014, K: 0.050, comment: "Waves"),
        ParameterOption(id: 13, F: 0.014, K: 0.053, comment: "Wavelets"),
    ]

    @State private var currentSelection: ParameterOption? = ParameterOption(id: 1, F: 0.055, K: 0.062, comment: "Cerebellum")

    var body: some View {
        
        VStack {
            Text("Select Simulation Parameters")
                .bold(true)
            Picker("Select option", selection: $currentSelection) {
                ForEach(parameterOptions) { option in
                    Text(option.description()).tag(
                        option as ParameterOption?
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
                        print("\(currentSelection.description())")
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
