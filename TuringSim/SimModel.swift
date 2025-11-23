//
//  File.swift
//  Turing
//
//  Created by Steve Roe on 11/15/25.
//

import Foundation

@Observable
class SimModel {

    var cellsPerEdge = 0
    var generation = 0
    var frame = 0
    let generationsPerFrame: Int = 1

    private var engine = SimEngine()
    private var levelGrid: [[Double]] = []

    init() {
        generation = 0
        cellsPerEdge = engine.cellsPerEdge
        levelGrid = Array(
            repeating: Array(repeating: 0.0, count: cellsPerEdge),
            count: cellsPerEdge
        )
    }

    func level(w: Int, h: Int) -> Double {
        levelGrid[w][h]
    }

    func seedRandomly() {
        engine.seedRandomly()
    }

    func evolve(count: Int = 1) {
        for _ in 0..<count {
            print("generation: \(generation)")
            if generation % generationsPerFrame == 0 {
                print("frame: \(frame)")
                print("Max A: \(engine.maxA()), Max B: \(engine.maxB())")
                frame += 1
            }
            let evolveResult = engine.evolve()
            levelGrid = evolveResult.grid
            generation = evolveResult.generation
        }
    }
}
