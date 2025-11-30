//
//  main.swift
//  TuringTool
//
//  Created by Steve Roe on 11/23/25.
//

import Foundation
//import TuringSim

let generations = 1000

print("Hello, World \(generations)!")

let engine = await SimEngineGraph()

let evolveResult = await engine.evolve(for: generations)

print("\(evolveResult.generation) Generations")
