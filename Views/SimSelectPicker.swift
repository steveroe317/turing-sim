//
//  SimSelectPicker.swift
//  TuringSim
//
//  Created by Stephen Roe on 5/2/26.
//

import SwiftUI

import SharedAssets

struct SimSelectPicker: View {
    var menuItems: [TuringPointItem]
    @Binding var selection: TuringPointItem?
    var showNilTag: Bool = false

    @Environment(TuringMapLabels.self) var mapLabels

    var body: some View {

        Picker("Select option", selection: $selection) {
            ForEach(menuItems) { option in
                Text(option.label(mapLabels: mapLabels)).tag(
                    option as TuringPointItem?
                )
            }
            if showNilTag {
                Text("").tag(nil as TuringPointItem?)
            }
        }
#if os(iOS)
        .pickerStyle(WheelPickerStyle())
#endif
        .background(Color.pickerBackground)
        .foregroundStyle(Color.pickerForeground)
        .tint(Color.pickerTint)
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 20.0)
        .padding(.vertical, 10.0)
    }
}
