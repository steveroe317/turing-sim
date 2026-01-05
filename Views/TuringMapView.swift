//
//  TuringMapView.swift
//  TuringSim
//
//  Created by Steve Roe on 12/22/25.
//

import SwiftUI

struct TuringMapView: View {
    let scale: CGFloat
    @Binding var f: Double
    @Binding var k: Double
    
    let span = 0.1
    let steps = 100

    var body: some View {
        ZStack {
            Image("turing-space-1500x1500")
                .resizable()
                .scaledToFit()
                .frame(width: scale, height: scale)
            Image("TuringMapMask_100x100_v1")
                .resizable()
                .scaledToFit()
                .frame(width: scale, height: scale)
                .opacity(0.3)
            Canvas { context, size in
                let paramPoint = mapParamsToCanvasPoint(f: f, k: k, size: size)
                drawScopeSight(at: paramPoint, in: context)
            }
        }
        .frame(width: scale, height: scale)
        .onTapGesture {
            location in
            (f, k) = mapCanvasPointToParams(x: location.x, y: location.y)
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged {
                    value in
                    (f, k) = mapCanvasPointToParams(x: value.location.x, y: value.location.y)
                }
        )
    }
    
    func clamp(to max_value: Double, _ value: Double) -> Double {
        max(0.0, min(value, max_value))
    }
    
    func mapParamsToCanvasPoint(f: Double, k: Double, size: CGSize) -> CGPoint {
        let edge = min(size.width, size.height)
        var x = edge * (clamp(to: span, k) / span)
        var y = edge - edge * (clamp(to: span, f) / span)
        if size.width < size.height {
            y += (size.height - size.width) / 2
        } else {
            x += (size.width - size.height) / 2
        }
        print(x, y)
        return CGPoint(x: x, y: y)
    }
    
    func mapCanvasPointToParams(x: CGFloat, y: CGFloat) -> (f: Double, k: Double) {
            let map_x = clamp(to: scale, x)
            let k = span * map_x / scale
            let map_y = clamp(to: scale, y)
            let f = span * (scale - map_y) / scale
        return (f: Double(f), k: Double(k))
    }
    
    func drawScopeSight(at center: CGPoint, in context: GraphicsContext) {
        let ringRadius = 8.0
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
    TuringMapView(scale: 300, f: $f, k: $k)
}
