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

struct SimControlView: View {
    @Binding var showSelectView: Bool
    @Binding var showExploreView: Bool

    @State private var buttonMaxWidth: CGFloat?

    @Environment(SimModel.self) var simModel

    var body: some View {
        ViewThatFits {
            HStack(alignment: .lastTextBaseline) {
                if simModel.isRunning() {
                    Button("Pause") {
                        simModel.pause()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)
                } else {
                    Button("Start") {
                        simModel.start()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)
                }

                Button("Reset", role: .destructive) {
                    simModel.reset()
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ButtonWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                    }
                )
                .frame(width: buttonMaxWidth)  // Apply the determined max width
                .padding(4)

                Button("Seed") {
                    simModel.seedRandomly()
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ButtonWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                    }
                )
                .frame(width: buttonMaxWidth)  // Apply the determined max width
                .padding(4)

                Button("Select") {
                    showSelectView = true
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ButtonWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                    }
                )
                .frame(width: buttonMaxWidth)  // Apply the determined max width
                .padding(4)
                .disabled(showExploreView)

                Button("Explore") {
                    showExploreView = true
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ButtonWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                    }
                )
                .frame(width: buttonMaxWidth)  // Apply the determined max width
                .padding(4)
                .disabled(showSelectView)
            }
            .onPreferenceChange(ButtonWidthPreferenceKey.self) { maxWidth in
                self.buttonMaxWidth = maxWidth
            }

            VStack {
                HStack(alignment: .lastTextBaseline) {
                    if simModel.isRunning() {
                        Button("Pause") {
                            simModel.pause()
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ButtonWidthPreferenceKey.self,
                                    value: geometry.size.width
                                )
                            }
                        )
                        .frame(width: buttonMaxWidth)  // Apply the determined max width
                        .padding(4)
                    } else {
                        Button("Start") {
                            simModel.start()
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ButtonWidthPreferenceKey.self,
                                    value: geometry.size.width
                                )
                            }
                        )
                        .frame(width: buttonMaxWidth)  // Apply the determined max width
                        .padding(4)
                    }

                    Button("Poke") {
                        simModel.seedRandomly()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)

                    Button("Reset") {
                        simModel.reset()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)
                }
                HStack(alignment: .lastTextBaseline) {
                    Button("Select") {
                        showSelectView = true
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)
                    .disabled(showExploreView)

                    Button("Explore") {
                        showExploreView = true
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ButtonWidthPreferenceKey.self,
                                value: geometry.size.width
                            )
                        }
                    )
                    .frame(width: buttonMaxWidth)  // Apply the determined max width
                    .padding(4)
                    .disabled(showSelectView)
                }
                .onPreferenceChange(ButtonWidthPreferenceKey.self) { maxWidth in
                    self.buttonMaxWidth = maxWidth
                }
            }
        }
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
