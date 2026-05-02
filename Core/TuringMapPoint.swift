//
//  TuringMapPoint.swift
//  TuringSim
//
//  Created by Steve Roe on 1/4/26.
//

import Foundation

struct TuringMapPoint: Hashable {
    let f: Double
    let k: Double
    
    func distance(to other: TuringMapPoint) -> Double {
        let df = f - other.f
        let dk = k - other.k
        return sqrt(df * df + dk * dk)
    }
}
