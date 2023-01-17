//
//  Text+TemperatureRange.swift
//  RadeonGadget
//
//  Created by Vithorio Polten on 17/01/23.
//

import Foundation
import SwiftUI

extension Text {
    func updateStyles(fromTemperature temperature: Int) -> Text {
        let range = range(forTemperature: temperature)
        return updateFontStyle(range: range)
    }
    
    func updateFontStyle(range: TemperatureRange) -> Text {
        switch range {
        case .cool:
            return coolTempFont()
        case .normal:
            return normalTempFont()
        case .high:
            return highTempFont()
        case .dangerous:
            return dangerousTempFont()
        case .unknown:
            return regularFont()
        }
    }
    
    func regularFont() -> Text {
        return self.font(Font.system(size: 14, weight: .regular))
            .foregroundColor(Color(NSColor.labelColor))
    }
    
    func coolTempFont() -> Text {
        return self.font(Font.system(size: 14, weight: .regular))
            .foregroundColor(Color(NSColor(hex: "#1EA4FF", alpha: 1.0)))
    }
    
    func normalTempFont() -> Text {
        return self.font(Font.system(size: 14, weight: .regular))
            .foregroundColor(Color(NSColor(hex: "#45B795", alpha: 1.0)))
    }
    
    func highTempFont() -> Text {
        return self.font(Font.system(size: 14, weight: .semibold))
            .foregroundColor(.orange)
    }
    
    func dangerousTempFont() -> Text {
        return self.font(Font.system(size: 14, weight: .bold))
            .foregroundColor(.red)
    }
}
