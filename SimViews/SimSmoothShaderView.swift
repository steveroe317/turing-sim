//
//  SimSmoothShaderView.swift
//  TuringSim
//
//  Created by Steve Roe on 1/7/26.
//

import SwiftUI

struct SimSmoothShaderView: View {
    @Environment(SimModel.self) var simModel
    
    
    func mapCellColor(level: Double) -> Color {
        
        let redPhase = level * Double.pi
        let greenPhase = redPhase + Double.pi / 3.0
        let bluePhase = greenPhase + Double.pi / 3.0
        
        let red = (sin(redPhase) + 1.0) / 2.0
        let green = (sin(greenPhase) + 1.0) / 2.0
        let blue = (sin(bluePhase) + 1.0) / 2.0
        
        return Color(red: red, green: green, blue: blue, opacity: 1)
    }
    
    func mapListColors(levels: [Double]) -> [Color] {
        var colors: [Color] = []
        colors.reserveCapacity(levels.count)
        for level in levels {
            colors.append(mapCellColor(level: level))
        }
        return colors
    }
    
    var body: some View {
        let levels = simModel.getCellLevels()
        let colors = mapListColors(levels: levels)
        let simWidth = Float(simModel.cellsPerEdge)
        
        Rectangle()
        .aspectRatio(1.0, contentMode: .fit)
        .visualEffect { content, proxy in
            content.colorEffect(ShaderLibrary.turingdrawsmooth(.float2(proxy.size), .float(simWidth), .colorArray(colors)))
        }
    }
}
#Preview {
    SimShaderView().environment(SimModel())
}
