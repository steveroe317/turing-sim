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
        Canvas { context, size in
            let minSpan = min(size.width, size.height)
            let cellSpan = minSpan / CGFloat(simModel.cellsPerEdge)
            let cellSize = CGSize(width: cellSpan, height: cellSpan)
            let xbase = (size.width - minSpan) / 2.0
            let ybase = (size.height - minSpan) / 2.0

            for w in 0..<simModel.cellsPerEdge {
                for h in 0..<simModel.cellsPerEdge {
                    let x = CGFloat(w) * cellSpan + xbase
                    let y = CGFloat(h) * cellSpan + ybase
                    let cellBase = CGPoint(x: x, y: y)
                    let cellRect = CGRect(origin: cellBase, size: cellSize)
                    let path = Path(
                        roundedRect: cellRect,
                        cornerRadius: CGFloat(0.0),
                        style: .circular
                    )
                    let cellColor = colorMap(level: simModel.level(w: w, h: h))
                    context.fill(path, with: .color(cellColor))
                    context.stroke(path, with: .color(cellColor))
                }
            }
        }
    }
}

#Preview {
    SimView().environment(SimModel())
}
