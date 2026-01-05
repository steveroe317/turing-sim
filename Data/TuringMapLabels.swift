//
//  TuringMapLabels.swift
//  TuringSim
//
//  Created by Steve Roe on 1/4/26.
//

import Foundation

@Observable
class TuringMapLabels {
    var labels: [TuringMapPoint: String] = [
        TuringMapPoint(f: 0.055, k:0.062) : "Cerebellum",
        TuringMapPoint(f: 0.042, k:0.059) : "Lace",
        TuringMapPoint(f: 0.038, k:0.061) : "Tiles",
        TuringMapPoint(f: 0.034, k:0.061) : "Strings",
        TuringMapPoint(f: 0.034, k:0.063) : "Mitosis",
        TuringMapPoint(f: 0.026, k:0.052) : "Mandala",
        TuringMapPoint(f: 0.022, k:0.050) : "Shimmer",
        TuringMapPoint(f: 0.026, k:0.056) : "Evolution",
        TuringMapPoint(f: 0.022, k:0.048) : "Tunnel",
        TuringMapPoint(f: 0.016, k:0.048) : "Reflections",
        TuringMapPoint(f: 0.014, k:0.040) : "Fog",
        TuringMapPoint(f: 0.014, k:0.050) : "Waves",
        TuringMapPoint(f: 0.014, k:0.053) : "Wavelets",
        ]
    
    func getLabel(forPoint point: TuringMapPoint) -> String? {
        return labels[point]
    }
}
