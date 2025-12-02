//
//  SimSnapshot.swift
//  TuringSim
//
//  Created by Steve Roe on 11/25/25.
//

import Foundation

struct SimSnapshot: Sendable {
    let generation: Int
    let cellsPerEdge: Int
    let A: [Double]
    let B: [Double]
}
