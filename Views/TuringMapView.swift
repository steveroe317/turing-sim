//
//  TuringMapView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/22/25.
//

import SwiftUI

struct TuringMapView: View {
    @Environment(SimModel.self) var simModel
    
    let span = 0.1
    let steps = 100

    var body: some View {
        ZStack {
            Image("turing-space-1500x1500")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            Image("TuringMapMask_100x100_v1")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .opacity(0.3)
            Canvas { context, size in
                let dotSize = CGSize(width: size.width / Double(steps), height: -size.height / Double(steps))
                let f = simModel.f
                let k = simModel.k
                let paramPoint = mapToCanvasPoint(f: f, k: k, size: size)
                drawDot(at: paramPoint, size: dotSize, in: context)
            }
        }
    }
    
    func clamp_to_span(_ value: Double) -> Double {
        max(0.0, min(value, span))
    }
    
    func mapToCanvasPoint(f: Double, k: Double, size: CGSize) -> CGPoint {
        let edge = min(size.width, size.height)
        var x = edge * (clamp_to_span(k) / span)
        var y = edge - edge * (clamp_to_span(f) / span)
        if size.width < size.height {
            y += (size.height - size.width) / 2
        } else {
            x += (size.width - size.height) / 2
        }
        return CGPoint(x: x, y: y)
    }
    
    func drawDot(at base: CGPoint, size: CGSize, in context: GraphicsContext) {
        let rect = CGRect(origin: base, size: size)
        let path = Circle().path(in: rect)
        context.fill(path, with: .color(.black))
    }
}

#Preview {
    TuringMapView()
}
