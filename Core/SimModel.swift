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
    var generationRate = 0.0
    
    var frame = 0
    let generationsPerFrame: Int = 50
    let frameSamples = 10
    private var frameTimes: [Double]
    private var frameGenerations: [Int]
    private var frameIndex = 0

    private var startRequested = false
    private var pauseRequested = false
    private var seedRequested = false
    private var resetRequested = false
    private var isSimRunning = true

    var f = 0.055
    var k = 0.117
    
    private var A: [Double] = []
    private var B: [Double] = []
    private var simTask: Task<Void, Error>?

    init() {
        frameTimes = Array(repeating: 0.0, count: frameSamples)
        frameGenerations = Array(repeating: 0, count: frameSamples)
        simTask = Task {
            let engine = await SimEngine()
            f = await engine.f
            k = await engine.k
            while true {
                isSimRunning = await engine.isRunning()
                
                let engine_f = await engine.f
                let engine_k = await engine.k
                if f != engine_f || k != engine_k {
                    f = (1000.0 * f).rounded() / 1000.0
                    k = (1000.0 * k).rounded() / 1000.0
                    await engine.set_f(f)
                    await engine.set_k(k)
                }

                let start = Date.now

                let snapshot = await engine.evolve(for: generationsPerFrame)
                
                if (generation == snapshot.generation) {
                    generationRate = 0.0
                } else {
                    generation = snapshot.generation
                    frameTimes[frameIndex] = Date.now.timeIntervalSince(start)
                    frameGenerations[frameIndex] = generationsPerFrame
                    generationRate =
                    Double(frameGenerations.reduce(0, +))
                    / frameTimes.reduce(0.0, +)
                    frameIndex = (frameIndex + 1) % frameSamples
                }
                
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
