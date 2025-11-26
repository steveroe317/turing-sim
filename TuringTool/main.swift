//
//  main.swift
//  TuringTool
//
//  Created by Steve Roe on 11/23/25.
//

import Foundation
import TuringSim

print("Hello, World!")

let engine = SimEngine()

let evolveResult = engine.evolve(for: 100)

print("\(evolveResult.generation) Generations")
