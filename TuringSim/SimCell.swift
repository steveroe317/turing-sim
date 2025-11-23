//
//  SimCell.swift
//  TuringSim
//
//  Created by Steve Roe on 11/22/25.
//

class SimCell {
    var A = 1.0
    var B = 0.0
    
    public func clear() {
        A = 0.0
        B = 0.0
    }
    
    public func copy(source: SimCell) {
        A = source.A
        B = source.B
    }
    
    public func level() -> Double {
        if A + B == 0.0 {
            return 1.0
        } else {
            return B / (A + B)
        }
    }
}

