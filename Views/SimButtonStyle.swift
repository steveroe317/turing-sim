//
//  SimButtonStyle.swift
//  TuringSim
//
//  Created by Steve Roe on 12/26/25.
//

import SwiftUI

struct SimButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(Color("ButtonBackground"))
            .clipShape(Capsule())
    }
}

#Preview {
    Button("Hello") {
        
    }.buttonStyle(SimButtonStyle());
}
