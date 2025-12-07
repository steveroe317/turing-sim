//
//  ContentView.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

import Combine
import SwiftUI

struct ContentView: View {

    @State private var simModel = SimModel()

    var body: some View {
        CoreView()
            .environment(simModel)
            .background(Color(.lightGray))
    }
}

#Preview {
    ContentView()
}
