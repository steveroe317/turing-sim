//
//  main.swift
//  TuringTool
//
//  Created by Steve Roe on 11/23/25.
//

import Foundation
//import TuringSim

let generations = 1

print("Hello, World \(generations)!")

let engine = await SimEngine()

let evolveResult = await engine.evolve(for: generations)

print("\(evolveResult.generation) Generations")

for (index, value) in evolveResult.B.enumerated() {
    if abs(value) > 0.00001 {
        print(value)
    }
}
