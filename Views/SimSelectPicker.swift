//
//  SimSelectPicker.swift
//  TuringSim
//
//  Created by Stephen Roe on 5/2/26.
//

import SwiftUI

struct SimSelectPicker: View {
    var menuItems: [TuringPointItem]
    @Binding var selection: TuringPointItem?
    
    @Environment(TuringMapLabels.self) var mapLabels
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        
        Picker("Select option", selection: $selection) {
            ForEach(menuItems) { option in
                Text(option.label(mapLabels: mapLabels)).tag(
                    option as TuringPointItem?
                )
            }
        }
#if os(iOS)
        .pickerStyle(WheelPickerStyle())
#endif
        .background(colorScheme == .light ? Color(Color.skyBlue) : Color.darkSkyBlue)
        .foregroundStyle(colorScheme == .light ? Color(.darkGray) : Color(.lightGray))
        .tint(colorScheme == .light ?  .black : .white)
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 20.0)
        .padding(.vertical, 10.0)
    }
}
