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
        ParameterOption(id: 1, F: 0.055, K: 0.117, comment: "Cerebellum"),
        ParameterOption(id: 2, F: 0.034, K: 0.095, comment: "Strings"),
        ParameterOption(id: 3, F: 0.034, K: 0.097, comment: "Splitting dots"),
        ParameterOption(id: 4, F: 0.038, K: 0.099, comment: "Tiles"),
        ParameterOption(id: 5, F: 0.042, K: 0.101, comment: "Lace"),
    ]

    @State private var currentSelection: ParameterOption? = ParameterOption(id: 1, F: 0.055, K: 0.117, comment: "Cerebellum")

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
                Button("Ok") {
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
                Button("Cancel") {
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
