//
//  SimEngineGraph.swift
//  TuringSim
//
//  Created by Steve Roe on 11/23/25.
//

import Foundation

@SimActor
class SimEngine {
    let cellsPerEdge = 201
    let totalCells : Int
    let seedRadius = 5
    var generation: Int = 0
    private var isSimRunning: Bool = true

    // Gray-Scott model parameters
    let dA = 1.0
    let dB = 0.5
    var f = 0.055
    var k = 0.062
    let r = 1.0

    private var A = [Double]()
    private var B = [Double]()
    private var diffusedA = [Double]()
    private var diffusedB = [Double]()

    struct DiffusionLink {
        let target: Int
        let weight: Double
    }

    private var diffusionLinksA = [[DiffusionLink]]()
    private var diffusionLinksB = [[DiffusionLink]]()

    init() {
        totalCells = cellsPerEdge * cellsPerEdge
        diffusedA = Array(repeating: 1.0, count: totalCells)
        diffusedB = Array(repeating: 0.0, count: totalCells)
        diffusionLinksA = Array(repeating: [], count: totalCells)
        diffusionLinksB = Array(repeating: [], count: totalCells)
        populateDiffusionLinks()
        resetGraph()
    }

    func set_f(_ f: Double) {
        self.f = f
    }

    func set_k(_ k: Double) {
        self.k = k
    }

    func resetGraph() {
        A = Array(repeating: 1.0, count: totalCells)
        B = Array(repeating: 0.0, count: totalCells)
        seed(x: cellsPerEdge / 2, y: cellsPerEdge / 2)
        generation = 0
    }

    func start() {
        isSimRunning = true
    }

    func stop() {
        isSimRunning = false
    }

    func isRunning() -> Bool {
        return isSimRunning
    }

    func planeCoordinates(fromLinear offset: Int) -> (x: Int, y: Int) {
        let (q, r) = offset.quotientAndRemainder(dividingBy: cellsPerEdge)

        return (x: q, y: r)
    }

    func linearCoordinates(fromX x: Int, fromY y: Int) -> Int {
        return x * cellsPerEdge + y
    }

    func populateDiffusionLinks() {
        diffusionLinksA = Array(repeating: [], count: totalCells)
        diffusionLinksB = Array(repeating: [], count: totalCells)

        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                let sourceIndex = linearCoordinates(fromX: w, fromY: h)
                for dw in -1...1 {
                    let w_target = (w + dw + cellsPerEdge) % cellsPerEdge
                    for dh in -1...1 {
                        let h_target = (h + dh + cellsPerEdge) % cellsPerEdge
                        let targetIndex = linearCoordinates(
                            fromX: w_target,
                            fromY: h_target
                        )
                        if dw == 0 && dh == 0 {
                            diffusionLinksA[sourceIndex].append(
                                DiffusionLink(target: targetIndex, weight: -dA)
                            )
                            diffusionLinksB[sourceIndex].append(
                                DiffusionLink(target: targetIndex, weight: -dB)
                            )
                        } else if dw == 0 || dh == 0 {
                            diffusionLinksA[sourceIndex].append(
                                DiffusionLink(
                                    target: targetIndex,
                                    weight: 0.2 * dA
                                )
                            )
                            diffusionLinksB[sourceIndex].append(
                                DiffusionLink(
                                    target: targetIndex,
                                    weight: 0.2 * dB
                                )
                            )
                        } else {
                            diffusionLinksA[sourceIndex].append(
                                DiffusionLink(
                                    target: targetIndex,
                                    weight: 0.05 * dA
                                )
                            )
                            diffusionLinksB[sourceIndex].append(
                                DiffusionLink(
                                    target: targetIndex,
                                    weight: 0.05 * dB
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    func diffuse() {

        for j in 0..<totalCells {
            diffusedA[j] = 0.0
            diffusedB[j] = 0.0
        }

        for j in 0..<totalCells {
            for link in diffusionLinksA[j] {
                diffusedA[link.target] += A[j] * link.weight
            }
            for link in diffusionLinksB[j] {
                diffusedB[link.target] += B[j] * link.weight
            }
        }
    }

   func evolve(for count: Int = 1) -> SimSnapshot {
        if isSimRunning {
            for _ in 0..<count {
                diffuse()
                for j in 0..<totalCells {
                    let a_only_evolve = A[j] + diffusedA[j] + f * (1.0 - A[j])
                    let b_only_evolve = B[j] + diffusedB[j] - (f + k) * B[j]
                    let a_to_b_transfer = min(r * A[j] * B[j] * B[j], a_only_evolve)
                    
                    let a = a_only_evolve - a_to_b_transfer
                    let b = max(b_only_evolve + a_to_b_transfer, 0.0)

                    A[j] = a
                    B[j] = b
                }
                generation += 1
            }
        }
        return SimSnapshot(
            generation: generation,
            cellsPerEdge: cellsPerEdge,
            A: A,
            B: B
        )
    }

    func seed(x: Int, y: Int) {
        for dw in -seedRadius...seedRadius {
            let w_target = (x + dw + cellsPerEdge) % cellsPerEdge
            for dh in -seedRadius...seedRadius {
                let h_target = (y + dh + cellsPerEdge) % cellsPerEdge
                B[linearCoordinates(fromX: w_target, fromY: h_target)] = 1.0
            }
        }
    }

    func seedRandomly() {
        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                if Int.random(in: 0..<10000) < 1 {
                    seed(x: w, y: h)
                }
            }
        }
    }
}
