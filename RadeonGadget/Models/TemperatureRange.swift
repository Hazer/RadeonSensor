//
//  TemperatureRange.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation

enum TemperatureRange {
    case unknown
    case cool
    case normal
    case high
    case dangerous
}

func range(forTemperature temp: Int) -> TemperatureRange {
    let range: TemperatureRange
    switch temp {
    case 0...37:
        range = .cool
    case 38...77:
        range = .normal
    case 78...87:
        range = .high
    default:
        range = .dangerous
    }
    return range
}

extension Int {
    func asTemperatureRange() -> TemperatureRange? {
        guard self > -1 else { return nil }
        return range(forTemperature: self)
    }
}
