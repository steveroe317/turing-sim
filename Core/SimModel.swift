//
//  File.swift
//  Turing
//
//  Created by Steve Roe on 11/15/25.
//

import Accelerate
import Foundation

@Observable
final class SimModel {

    var cellsPerEdge = 0
    
    var generation = 0
    var generationRate = 0.0
    
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
    var k = 0.062
    
    private var A: [Double] = []
    private var B: [Double] = []
    private var simTask: Task<Void, Error>?

    // MARK: - Simulation Engine
    
    init() {
        frameTimes = Array(repeating: 0.0, count: frameSamples)
        frameGenerations = Array(repeating: 0, count: frameSamples)
        simTask = Task {
            let engine = await SimEngine()
            await loadSimParameters(from: engine)
            while true {
                await processSimParameterChanges(for: engine)
                let simCellsModified = await processRequestFlags(for: engine)
                isSimRunning = await engine.isRunning()
                if !isSimRunning && !simCellsModified {
                    try await Task.sleep(for: .milliseconds(50))
                    continue // Skip snapshot processing.
                }

                let start = Date.now

                let snapshot = await engine.evolve(for: generationsPerFrame)
                cellsPerEdge = snapshot.cellsPerEdge
                A = snapshot.A
                B = snapshot.B

                // Update average sim generatation rate.
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
            }
        }
    }

    deinit {
        simTask?.cancel()
    }
    
    // MARK: Simulation Engine Observation

    func cellLevel(w: Int, h: Int) -> Double {
        let j = w * cellsPerEdge + h
        return abLevel(a: A[j], b: B[j])
    }
    
    func getCellLevels() -> [Double] {
        var levels: [Double] = []
        levels.reserveCapacity(A.count)
        for (a, b) in zip(A, B) {
            levels.append(abLevel(a: a, b: b))
        }
        return levels
    }
    
    func getAFloats() -> [Float] {
        return vDSP.doubleToFloat(A)
    }
    
    func getBFloats() -> [Float] {
        return vDSP.doubleToFloat(B)
    }

    func isRunning() -> Bool {
        return isSimRunning
    }
    
    // MARK: Simulation Engine Control

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
    
    // MARK: - Private Methods
    
    private func processRequestFlags(for engine: SimEngine) async -> Bool {
        var simCellsModified = false
        
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
            simCellsModified = true
        }
        if resetRequested {
            await engine.resetGraph()
            resetRequested = false
            simCellsModified = true
        }
        
        return simCellsModified
    }
    
    private func loadSimParameters(from engine: SimEngine) async {
        f = await engine.f
        k = await engine.k
    }
    
    private func processSimParameterChanges(for engine: SimEngine) async {
        let engine_f = await engine.f
        let engine_k = await engine.k
        if f != engine_f || k != engine_k {
            f = (1000.0 * f).rounded() / 1000.0
            k = (1000.0 * k).rounded() / 1000.0
            await engine.set_f(f)
            await engine.set_k(k)
        }
    }
    
    private func abLevel(a: Double, b: Double) -> Double {
        return (a + b == 0) ? 1.0 : b / (a + b)
    }
}
