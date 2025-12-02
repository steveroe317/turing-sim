//
//  File.swift
//  Turing
//
//  Created by Steve Roe on 11/15/25.
//

import Foundation

@Observable
final class SimModel {

    var cellsPerEdge = 0
    var generation = 0
    var frame = 0
    let generationsPerFrame: Int = 1
    private var startRequested = false
    private var pauseRequested = false
    private var seedRequested = false
    private var resetRequested = false
    private var isSimRunning = true

    private var A: [Double] = []
    private var B: [Double] = []
    private var simTask: Task<Void, Error>?

    init() {
        simTask = Task {
            let engine = await SimEngine()
            while true {
                isSimRunning = await engine.isRunning()

                let snapshot = await engine.evolve(for: 50)
                generation = snapshot.generation
                cellsPerEdge = snapshot.cellsPerEdge
                A = snapshot.A
                B = snapshot.B

                if startRequested {
                    await engine.start()
                    startRequested = false
                }
                if pauseRequested {
                    await engine.stop()
                    pauseRequested = false
                }
                if seedRequested {
                    await engine.seedRandomly()
                    seedRequested = false
                }
                if resetRequested {
                    await engine.resetGraph()
                    resetRequested = false
                }
            }
        }
    }

    deinit {
        simTask?.cancel()
    }

    func level(w: Int, h: Int) -> Double {
        let j = w * cellsPerEdge + h
        return (A[j] + B[j] == 0) ? 1.0 : B[j] / (A[j] + B[j])
    }

    func isRunning() -> Bool {
        return isSimRunning
    }

    func start() {
        startRequested = true
    }

    func pause() {
        pauseRequested = true
    }

    func seedRandomly() {
        seedRequested = true
    }

    func reset() {
        resetRequested = true
    }
}
