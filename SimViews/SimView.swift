import SwiftUI

struct SimView: View {
    @Environment(SimModel.self) var simModel

    func colorMap(level: Double) -> Color {

        let redPhase = level * Double.pi
        let greenPhase = redPhase + Double.pi / 3.0
        let bluePhase = greenPhase + Double.pi / 3.0

        let red = (sin(redPhase) + 1.0) / 2.0
        let green = (sin(greenPhase) + 1.0) / 2.0
        let blue = (sin(bluePhase) + 1.0) / 2.0

        return Color(red: red, green: green, blue: blue, opacity: 1)
    }

    var body: some View {
        SimTileView()
    }
}

#Preview {
    SimView().environment(SimModel())
}
