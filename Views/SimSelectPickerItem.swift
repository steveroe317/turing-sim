//
//  SimSelectPickerItem.swift
//  TuringSim
//
//  Created by Stephen Roe on 5/2/26.
//

import Foundation

struct TuringPointItem: Identifiable, Hashable {
    let id: Int
    let point: TuringMapPoint

    func label(mapLabels: TuringMapLabels) -> String {
        return mapLabels.getLabel(forPoint: point) ?? ""
    }
}
