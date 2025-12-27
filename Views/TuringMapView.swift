//
//  TuringMapView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/22/25.
//

import SwiftUI

struct TuringMapView: View {
    @Binding var f: Double
    @Binding var k: Double
    
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
                let cellEdge = min(size.width, size.height) / Double(steps)
                let paramPoint = mapToCanvasPoint(f: f, k: k, size: size)
                drawScopeSight(at: paramPoint, cellEdge: cellEdge, in: context)
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
    
    func drawScopeSight(at base: CGPoint, cellEdge: Double, in context: GraphicsContext) {
        let ringRadius = 8.0
        
        let center = CGPoint(x: base.x + cellEdge / 2, y: base.y + cellEdge / 2)
        
        let circleBounds = CGRect(
            x: center.x - ringRadius,
            y: center.y - ringRadius,
            width: 2 * ringRadius,
            height: 2 * ringRadius)
        context.stroke(
            Circle()
                .path(in: circleBounds),
            with: .color(.black))
        
        let innerLineRadius: CGFloat = 2.0
        let outerLineRadius: CGFloat = 12.0
        
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y + innerLineRadius))
        path.addLine(to: CGPoint(x: center.x, y: center.y + outerLineRadius))
        context.stroke(path, with: .color(.black))
        
        path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - innerLineRadius))
        path.addLine(to: CGPoint(x: center.x, y: center.y - outerLineRadius))
        context.stroke(path, with: .color(.black))

        path = Path()
        path.move(to: CGPoint(x: center.x + innerLineRadius, y: center.y))
        path.addLine(to: CGPoint(x: center.x + outerLineRadius, y: center.y))
        context.stroke(path, with: .color(.black))

        path = Path()
        path.move(to: CGPoint(x: center.x - innerLineRadius, y: center.y))
        path.addLine(to: CGPoint(x: center.x - outerLineRadius, y: center.y))
        context.stroke(path, with: .color(.black))
    }
}

#Preview {
    @Previewable @State var f: Double = 0.05
    @Previewable @State var k: Double = 0.05
    TuringMapView(f: $f, k: $k)
}
