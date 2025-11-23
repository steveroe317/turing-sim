//
//  SimEngine.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

import Foundation

class SimEngine {
    let cellsPerEdge = 101
    let seedRadius = 5
    var generation: Int = 0

    // Gray-Scott model parameters
    let dA = 1.0
    let dB = 0.5
    let f = 0.055
    let k = 0.117
    let r = 1.0

    var simGrid = [[SimCell]]()
    private var evolveGrid = [[SimCell]]()
    private var deltaGrid = [[SimCell]]()

    init() {
        simGrid = createGrid()
        deltaGrid = createGrid()
        seed(x: cellsPerEdge / 2, y: cellsPerEdge / 2)
    }

    func createGrid() -> [[SimCell]] {
        var newGrid = [[SimCell]]()

        for _ in 0..<cellsPerEdge {
            var newRow = [SimCell]()
            for _ in 0..<cellsPerEdge {
                newRow.append(SimCell())
            }
            newGrid.append(newRow)
        }

        return newGrid
    }

    func maxA() -> Double {
        var max: Double = -1.0
        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                if simGrid[w][h].A > max {
                    max = simGrid[w][h].A
                }
            }
        }
        return max
    }

    func maxB() -> Double {
        var max: Double = -1.0
        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                if simGrid[w][h].B > max {
                    max = simGrid[w][h].B
                }
            }
        }
        return max
    }

    func level(w: Int, h: Int) -> Double {
        simGrid[w][h].level()
    }

    func diffuseDeltaGrid() {

        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                deltaGrid[w][h].clear()
            }
        }

        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                for dw in -1...1 {
                    let w_target = (w + dw + cellsPerEdge) % cellsPerEdge
                    for dh in -1...1 {
                        let h_target = (h + dh + cellsPerEdge) % cellsPerEdge
                        if dw == 0 && dh == 0 {
                            deltaGrid[w_target][h_target].A -=
                                simGrid[w][h].A * dA
                            deltaGrid[w_target][h_target].B -=
                                simGrid[w][h].B * dB
                        } else if dw == 0 || dh == 0 {
                            deltaGrid[w_target][h_target].A +=
                                simGrid[w][h].A * 0.2 * dA
                            deltaGrid[w_target][h_target].B +=
                                simGrid[w][h].B * 0.2 * dB
                        } else {
                            deltaGrid[w_target][h_target].A +=
                                simGrid[w][h].A * 0.05 * dA
                            deltaGrid[w_target][h_target].B +=
                                simGrid[w][h].B * 0.05 * dB
                        }
                    }
                }
            }
        }
    }

    func evolve(count: Int = 1) -> (generation: Int, grid:[[Double]]) {
        for _ in 0..<count {
            diffuseDeltaGrid()
            for w in 0..<cellsPerEdge {
                for h in 0..<cellsPerEdge {
                    let cell = simGrid[w][h]
                    let delta = deltaGrid[w][h]
                    let a =
                        cell.A + delta.A + f * (1.0 - cell.A) - r * cell.A
                        * cell.B * cell.B
                    let b =
                        cell.B + delta.B - k * cell.B + r * cell.A * cell.B
                        * cell.B
                    cell.A = a
                    cell.B = b
                }
            }
            generation += 1
        }
        return (generation: generation, grid: levelGrid())
    }

    func levelGrid() -> [[Double]] {
        var grid: [[Double]] = []
        for w in 0..<cellsPerEdge {
            var row: [Double] = []
            for h in 0..<cellsPerEdge {
                row.append(simGrid[w][h].level())
            }
            grid.append(row)
        }
        return grid
    }

    func seed(x: Int, y: Int) {
        for dw in -seedRadius...seedRadius {
            let w_target = (x + dw + cellsPerEdge) % cellsPerEdge
            for dh in -seedRadius...seedRadius {
                let h_target = (y + dh + cellsPerEdge) % cellsPerEdge
                simGrid[w_target][h_target].B = 1.0
            }
        }
    }

    func seedRandomly() {
        for w in 0..<cellsPerEdge {
            for h in 0..<cellsPerEdge {
                if Int.random(in: 0..<3000) < 1 {
                    seed(x: w, y: h)
                }
            }
        }
    }
}
