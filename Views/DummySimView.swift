//
//  DummySimView.swift
//  TuringSim
//
//  Created by Steve Roe on 1/6/26.
//

import SwiftUI

struct DummySimView: View {
    var body: some View {
        Rectangle()
         .aspectRatio(1.0, contentMode: .fit)
         .background(.gray)
    }
}

#Preview {
    DummySimView()
}
