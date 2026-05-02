//
//  SimControlView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/3/25.
//

import SwiftUI

struct ButtonWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct MeasuredWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                Color.clear.preference(key: ButtonWidthPreferenceKey.self, value: geo.size.width)
            }
        )
    }
}

struct SimControlView: View {
    @Binding var showSelectView: Bool
    @Binding var showExploreView: Bool

    @State private var buttonMaxWidth: CGFloat?

    @Environment(SimModel.self) var simModel

    var body: some View {
        ViewThatFits {
            HStack(alignment: .lastTextBaseline) {
                StartPauseButton(buttonMaxWidth: $buttonMaxWidth)
                SeedButton(buttonMaxWidth: $buttonMaxWidth)
                ResetButton(buttonMaxWidth: $buttonMaxWidth)
                SetBoolButton(title:"Select", value: $showSelectView, buttonMaxWidth:
                                $buttonMaxWidth)
                .disabled(showExploreView)
                SetBoolButton(title:"Explore", value: $showExploreView, buttonMaxWidth:
                                $buttonMaxWidth)
                .disabled(showSelectView)
            }
            .onPreferenceChange(ButtonWidthPreferenceKey.self) {
                buttonMaxWidth = $0
            }

            VStack {
                HStack(alignment: .lastTextBaseline) {
                    StartPauseButton(buttonMaxWidth: $buttonMaxWidth)
                    SeedButton(buttonMaxWidth: $buttonMaxWidth)
                    ResetButton(buttonMaxWidth: $buttonMaxWidth)
                }
                HStack(alignment: .lastTextBaseline) {
                    SetBoolButton(title:"Select", value: $showSelectView, buttonMaxWidth:
                                    $buttonMaxWidth)
                    .disabled(showExploreView)
                    SetBoolButton(title:"Explore", value: $showExploreView, buttonMaxWidth:
                                    $buttonMaxWidth)
                    .disabled(showSelectView)
                }
            }
            .onPreferenceChange(ButtonWidthPreferenceKey.self) {
                buttonMaxWidth = $0
            }
        }
    }
}

private struct StartPauseButton: View {
    @Binding var buttonMaxWidth: CGFloat?
    
    @Environment(SimModel.self) var simModel

    var body: some View {
        if simModel.isRunning() {
            Button("Pause") {
                simModel.pause()
            }
            .modifier(MeasuredWidthModifier())
            .frame(width: buttonMaxWidth)  // Apply the determined max width
            .padding(4)
        } else {
            Button("Start") {
                simModel.start()
            }
            .modifier(MeasuredWidthModifier())
            .frame(width: buttonMaxWidth)  // Apply the determined max width
            .padding(4)
        }
    }
}

private struct SeedButton: View {
    @Binding var buttonMaxWidth: CGFloat?
    
    @Environment(SimModel.self) var simModel

    var body: some View {
        Button("Seed") {
            simModel.seedRandomly()
        }
        .modifier(MeasuredWidthModifier())
        .frame(width: buttonMaxWidth)  // Apply the determined max width
        .padding(4)
    }
}

private struct ResetButton: View {
    @Binding var buttonMaxWidth: CGFloat?
    
    @Environment(SimModel.self) var simModel

    var body: some View {
        Button("Reset") {
            simModel.reset()
        }
        .modifier(MeasuredWidthModifier())
        .frame(width: buttonMaxWidth)  // Apply the determined max width
        .padding(4)
    }
}

private struct SetBoolButton: View {
    let title: String
    @Binding var value: Bool
    @Binding var buttonMaxWidth: CGFloat?
    
    var body: some View {
        Button(title) {
            value = true
        }
        .modifier(MeasuredWidthModifier())
        .frame(width: buttonMaxWidth)  // Apply the determined max width
        .padding(4)
    }
}

#Preview {
    @Previewable @State var showParameterSelection: Bool = false
    @Previewable @State var showExploreView: Bool = false
    SimControlView(
        showSelectView: $showParameterSelection,
        showExploreView: $showExploreView
    ).environment(SimModel())
}
