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
        return sqrt(pow(f - other.f, 2) + pow(k - other.k, 2))
    }
}
